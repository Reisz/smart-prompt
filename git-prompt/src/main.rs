use std::fmt::{self, Display};

use ansi_term::{Color::Fixed, Style};
use git2::{BranchType, Oid, Reference, Repository, Statuses};

fn branch(repo: &Repository) -> impl Display {
    if repo.head_detached().unwrap() {
        return Fixed(199).bold().paint("<detached>");
    }

    // Use the reference here to avoid resolving a branch with no commits
    // This will happen in a repository created by `git init`
    let head = repo.find_reference("HEAD").unwrap();
    let name = head
        .symbolic_target()
        .unwrap()
        .strip_prefix("refs/heads/")
        .unwrap();

    let color = match name {
        "main" | "master" => 26,
        "develop" => 99,
        name if name.starts_with("release") => 34,
        _ => 214,
    };

    Fixed(color).bold().paint(name.to_owned())
}

#[derive(Debug, Default)]
struct StatusCounts {
    /// Fully staged files
    staged: u32,
    /// Partially staged files
    partial: u32,
    /// Fully unstaged files
    unstaged: u32,
    //// TODO: figure out
    conflicted: u32,
}

impl Display for StatusCounts {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let write = |f: &mut fmt::Formatter<'_>, num, char, style: Style| {
            if num > 0 {
                write!(f, " {}{}{}{}", style.prefix(), char, num, style.suffix())
            } else {
                Ok(())
            }
        };

        write(f, self.staged, '○', Fixed(34).bold())?;
        write(f, self.partial, '↔', Fixed(220).bold())?;
        write(f, self.unstaged, '?', Fixed(196).bold())?;
        write(f, self.conflicted, 'C', Fixed(201).bold())?;

        Ok(())
    }
}

fn count_statuses(statuses: Statuses) -> StatusCounts {
    let mut result = StatusCounts::default();

    for status in statuses.iter() {
        let status = status.status();
        if status.is_conflicted() {
            result.conflicted += 1;
        }

        // This uses binary representation defined at
        // https://github.com/libgit2/libgit2/blob/main/include/git2/status.h
        let bits = status.bits();
        let index_bits = bits & ((1 << 5) - 1);
        let wt_bits = (bits >> 7) & ((1 << 5) - 1);

        if index_bits > 0 && wt_bits > 0 {
            result.partial += 1;
        } else if index_bits > 0 {
            result.staged += 1;
        } else if wt_bits > 0 {
            result.unstaged += 1;
        }
    }

    result
}

struct Commit(Option<Oid>);

impl Display for Commit {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if let Some(oid) = self.0 {
            let style = Fixed(242).bold();

            let prefix = style.prefix();
            let suffix = style.suffix();

            write!(f, "@{}{:.7}{}", prefix, oid, suffix)?;
        }

        Ok(())
    }
}

fn commit(head: &Option<Reference>) -> Commit {
    Commit(head.as_ref().and_then(|h| h.target()))
}

struct StashHeight(usize);

impl Display for StashHeight {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if self.0 > 0 {
            let style = Fixed(63).bold();
            write!(f, " | {}≡{}{}", style.prefix(), self.0, style.suffix())?;
        }
        Ok(())
    }
}

fn stash_height(repository: &mut Repository) -> StashHeight {
    let mut height = 0;
    repository
        .stash_foreach(|_, _, _| {
            height += 1;
            true
        })
        .unwrap();
    StashHeight(height)
}

#[derive(Debug, Default)]
struct RemoteDivergence {
    push_count: usize,
    pull_count: usize,
}

impl Display for RemoteDivergence {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let style = Fixed(220).bold();

        let prefix = style.prefix();
        let suffix = style.suffix();

        if self.push_count > 0 || self.pull_count > 0 {
            write!(f, " |")?;
        }

        if self.push_count > 0 {
            write!(f, " {}▲{}{}", prefix, self.push_count, suffix)?;
        }

        if self.pull_count > 0 {
            write!(f, " {}▼{}{}", prefix, self.pull_count, suffix)?;
        }

        Ok(())
    }
}

fn remote_divergence(repository: &mut Repository) -> impl Display {
    let mut result = RemoteDivergence::default();

    if let Ok(head) = repository.head() {
        if head.is_branch() {
            let current_branch = repository
                .find_branch(head.shorthand().unwrap(), BranchType::Local)
                .unwrap();
            if let Ok(remote) = current_branch.upstream() {
                let mut revwalk = repository.revwalk().unwrap();

                let head = head.name().unwrap();
                let remote = remote.name().unwrap().unwrap();

                revwalk
                    .push_range(&format!("{}..{}", remote, head))
                    .unwrap();
                result.push_count = revwalk.count();

                let mut revwalk = repository.revwalk().unwrap();
                revwalk
                    .push_range(&format!("{}..{}", head, remote))
                    .unwrap();
                result.pull_count = revwalk.count();
            }
        }
    }

    result
}

fn main() {
    if let Ok(mut repository) = Repository::discover(".") {
        let stash = stash_height(&mut repository);
        let branch = branch(&repository);
        let remote = remote_divergence(&mut repository);
        let statuses = repository.statuses(None).unwrap();
        print!(
            "({} {}{}{}{}{}",
            Fixed(160).bold().paint("Git"),
            branch,
            commit(&repository.head().ok()),
            count_statuses(statuses),
            stash,
            remote,
        );
    }
}
