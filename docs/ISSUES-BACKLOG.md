# Demo backlog

Copy these into the repository so the board and the charts have real shape before the
presentation. Titles only; the body can stay empty.

**Assignees matter.** Insights groups by assignee. Use at least three different people
(or three labels standing in for people) and spread the work unevenly so the charts
show an imbalance.

## Authentication

| # | Title | Label | Assignee |
| --- | --- | --- | --- |
| 1 | Sign-in form hangs on submit | bug | ana |
| 2 | Password recovery link missing from sign-in page | enhancement | ana |
| 3 | Session expires after 5 minutes on mobile | bug | luis |
| 4 | Show password error inline instead of alert | enhancement | luis |
| 5 | Rate limit login attempts | enhancement | marta |
| 6 | Support passkeys | enhancement | — |

## Frontend

| # | Title | Label | Assignee |
| --- | --- | --- | --- |
| 7 | Layout breaks below 360px width | bug | luis |
| 8 | Focus outline invisible on dark mode | bug | marta |
| 9 | Add loading state to submit button | enhancement | ana |
| 10 | Localize validation messages | enhancement | — |
| 11 | Reduce bundle size below 50 kB | enhancement | luis |
| 12 | Replace inline styles with a stylesheet | refactor | marta |

## API

| # | Title | Label | Assignee |
| --- | --- | --- | --- |
| 13 | Return 401 instead of 500 for expired tokens | bug | ana |
| 14 | Document the auth endpoints | documentation | marta |
| 15 | Add request id to error responses | enhancement | ana |
| 16 | Timeout external identity provider calls | bug | luis |
| 17 | Validate email format server side | bug | marta |

## Infrastructure

| # | Title | Label | Assignee |
| --- | --- | --- | --- |
| 18 | Add CI workflow for pull requests | enhancement | luis |
| 19 | Pin Node version in CI | enhancement | ana |
| 20 | Enable dependency alerts | enhancement | marta |
| 21 | Staging environment missing environment variables | bug | — |
| 22 | Archive stale board items automatically | enhancement | marta |

## Documentation

| # | Title | Label | Assignee |
| --- | --- | --- | --- |
| 23 | Document the issue template selection | documentation | ana |
| 24 | Add contributing guide | documentation | — |

## Suggested distribution

- **ana**: 7 items
- **luis**: 6 items
- **marta**: 6 items
- **unassigned**: 5 items

Also close 4 or 5 of them before the talk so the `Done` column is not empty and the
Burn up chart has a completed line.

## Optional: create them in bulk

Only if you do not want to click 24 times. Run it from the repository root, signed in
with `gh`.

```powershell
$issues = @(
  "Sign-in form hangs on submit",
  "Password recovery link missing from sign-in page",
  "Session expires after 5 minutes on mobile",
  "Show password error inline instead of alert",
  "Rate limit login attempts",
  "Support passkeys",
  "Layout breaks below 360px width",
  "Focus outline invisible on dark mode",
  "Add loading state to submit button",
  "Localize validation messages",
  "Reduce bundle size below 50 kB",
  "Replace inline styles with a stylesheet",
  "Return 401 instead of 500 for expired tokens",
  "Document the auth endpoints",
  "Add request id to error responses",
  "Timeout external identity provider calls",
  "Validate email format server side",
  "Add CI workflow for pull requests",
  "Pin Node version in CI",
  "Enable dependency alerts",
  "Staging environment missing environment variables",
  "Archive stale board items automatically",
  "Document the issue template selection",
  "Add contributing guide"
)

foreach ($title in $issues) {
  gh issue create --title $title --body "" --label "enhancement"
}
```

Assignees are not set by that loop. Assign them from the board, where the operation is
faster, or add `--assignee <login>` per issue.
