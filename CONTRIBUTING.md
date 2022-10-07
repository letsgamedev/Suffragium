# Contributing to Suffragium

There are many ways, how you can contribute and be part of this project.

The most meaningful are:

- Open a pull request
- Vote
- Give feedback

---

## Open a Pull Request

If you want to add a feature or fix a bug. Pull Requests are the way to go. Try to keep them short and simple and follow the developer guide.

### Developer guide

#### REQUIRED

- Follow the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#gdscript-style-guide)
- Use [Scony's godot gdscript tollkit](https://github.com/Scony/godot-gdscript-toolkit/) to validate the Pull Request

#### RECOMMENDED

- Folder names are in snake_case
- File names are in snake_case
- Node names are in PascalCase

---

## How to Vote

Place a :+1: or :-1: emoji on the initial post of a pull request.
If you're creating a PR to fix a blocking issue that currently breaks the project, i.e. a critical fix that shouldn't be delayed, use the :rocket: emoji.
Once the merge conditions are met, the pull request can be merged.

## Merge pull request conditions

If one of them is true, the PR will me merged.

- **Last commit is 24h or older** and **has more than 10 votes** and **75% positive votes**
- **Last commit is 72h or older** and **75% positive votes**
- **PR fixes a blocking issue** that prevents the main branch from editing/building/running (e.g. due to engine changes) and has at least **2 :rocket: votes**, excluding the author

## Close pull request without merging conditions

If its true, the pull request / draft is considered as blocked and will be closed

- **Last commit is 20 days or older**
