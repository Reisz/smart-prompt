use std::fmt::{self, Display};

use ansi_term::{Color::Fixed, Style};
use git2::{Reference, Repository, Statuses};

fn branch<'a>(head: &'a Reference) -> impl Display + 'a {
    if head.is_branch() {
        let name = head.shorthand().unwrap();

        let color = match name {
            "main" | "master" => 26,
            "develop" => 99,
            name if name.starts_with("release") => 34,
            _ => 214,
        };

        Fixed(color).bold().paint(name)
    } else {
        Fixed(199).bold().paint("<detached>")
    }
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

fn commit<'a>(head: &'a Reference) -> impl Display + 'a {
    Fixed(242)
        .bold()
        .paint(format!("{:.7}", head.target().unwrap()))
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

fn main() {
    if let Ok(mut repository) = Repository::discover(".") {
        let stash = stash_height(&mut repository);
        let head = repository.head().unwrap();
        let statuses = repository.statuses(None).unwrap();
        print!(
            "({} {}@{}{}{}",
            Fixed(160).bold().paint("Git"),
            branch(&head),
            commit(&head),
            count_statuses(statuses),
            stash
        );
    }
}
