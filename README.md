# demo-gh-projects

Sample repository used to demonstrate how GitHub Issues templates, Projects boards,
workflows and Insights fit together.

The application code is intentionally minimal. Its only job is to make the repository
look like a real project while the presentation focuses on the collaboration tooling.

## What is inside

| Path | Purpose | What it demonstrates |
| --- | --- | --- |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | Bug report form | Required fields, dropdowns, single-select, code block rendering |
| `.github/ISSUE_TEMPLATE/feature_request.yml` | Feature request form | Multi-select dropdown, optional fields |
| `.github/ISSUE_TEMPLATE/config.yml` | Template chooser config | `blank_issues_enabled: false`, contact links |
| `.github/PULL_REQUEST_TEMPLATE.md` | Pull request body | Link between a PR and a project item |
| `src/` | Minimal sign-in page | Context for the issues |
| `scripts/setup-project.ps1` | Provisions the board | Project, repository link, custom fields |
| `scripts/seed-issues.ps1` | Creates the backlog | Volume and assignee spread for the charts |
| `scripts/preflight.ps1` | Verifies the setup | Catches the failures that happen on stage |
| `docs/` | Presenter material | Runbook, setup, backlog and public examples |

## Setup

```bash
git init
git add .
git commit -m "chore: initial demo repository"
gh repo create demo-gh-projects --public --source=. --push
```

## Important

The project board, its views, its workflows and its charts live in **GitHub Projects**,
not in this repository. Nothing under `.github/` can provision them. They are created
and configured in the browser.
