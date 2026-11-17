# Automated setup

This repository can be provisioned from a terminal in a few minutes.

## What is automated and what is not

| Step | Automated | How |
| --- | --- | --- |
| Repository, templates, app code | Yes | `git push` |
| Project creation | Yes | `gh project create` |
| Link project to repository | Yes | `gh project link` |
| Custom fields (`Status`, `Priority`, `Size`) | Yes | `gh project field-create` |
| Backlog of 24 issues with labels | Yes | `gh issue create` |
| Assignees | Yes, for existing collaborators | `gh issue create --assignee` |
| Views (`Board`, `Roadmap`) | **No** | Browser only |
| Built-in workflows (auto-add, item closed) | **No** | Browser only |
| Insights charts | **No** | Browser only |

Views, workflows and charts have no CLI command and no public API. A script that
claims to create them is wrong. The script prints them as manual steps instead.

## Prerequisites

```bash
gh auth login
gh auth refresh -s project
```

The `project` scope is required. Without it every `gh project` call fails.

## Order

```powershell
# 0. publish the repository first
git init
git add .
git commit -m "chore: initial demo repository"
gh repo create demo-gh-projects --public --source=. --push

# 1. create the board, link it, create the fields
#    then follow the printed manual steps (workflows, views)
./scripts/setup-project.ps1

# 2. create the backlog
#    assignees must already be collaborators on the repository
./scripts/seed-issues.ps1 -Assignees ana,luis,marta -CloseCount 5

# 3. verify
./scripts/preflight.ps1
```

## Why `Status` is created by hand

`gh project create` has no `--template` flag. A project created from the CLI starts
with only the `Title` field. The `Status` field that the Board template would give you
does not exist, so `setup-project.ps1` creates it with `Todo`, `In Progress` and `Done`.
Without it the *Item closed* workflow has nothing to switch to.

## If assignees fail

Assignees must be users with access to the repository. A personal repository accepts
only the owner. Options:

- Create the demo repository under an organization and invite the other accounts.
- Assign every issue to yourself and present the chart honestly as a single-person
  workload.
- Use labels as stand-ins for people and group the chart by label instead.

## Teardown

```powershell
gh project delete <number> --owner @me
gh repo delete <owner/repo> --yes
```
