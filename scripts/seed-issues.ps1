<#
.SYNOPSIS
    Creates the demo backlog: labels, issues and a few closed items.

.DESCRIPTION
    Insights is empty on a board with three cards. This script creates a
    backlog with enough volume and enough assignee spread for the charts to
    show real shape.

    Assignees must already have access to the repository. Logins that cannot
    be assigned are rejected by the API and reported, not silently dropped.

.EXAMPLE
    ./scripts/seed-issues.ps1

.EXAMPLE
    ./scripts/seed-issues.ps1 -Assignees ana,luis,marta -CloseCount 5
#>
[CmdletBinding()]
param(
    [string[]]$Assignees = @(),
    [int]$CloseCount = 5,
    [switch]$DryRun
)

$ErrorActionPreference = "Continue"

function Fail([string]$Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "gh is not authenticated. Run: gh auth login" }

gh repo view | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "Not inside a GitHub repository. Run from the repo root." }

$backlog = @(
    @{ Title = "Sign-in form hangs on submit";                    Label = "bug" }
    @{ Title = "Password recovery link missing from sign-in page"; Label = "enhancement" }
    @{ Title = "Session expires after 5 minutes on mobile";        Label = "bug" }
    @{ Title = "Show password error inline instead of alert";      Label = "enhancement" }
    @{ Title = "Rate limit login attempts";                        Label = "enhancement" }
    @{ Title = "Support passkeys";                                 Label = "enhancement" }
    @{ Title = "Layout breaks below 360px width";                  Label = "bug" }
    @{ Title = "Focus outline invisible on dark mode";             Label = "bug" }
    @{ Title = "Add loading state to submit button";               Label = "enhancement" }
    @{ Title = "Localize validation messages";                     Label = "enhancement" }
    @{ Title = "Reduce bundle size below 50 kB";                   Label = "enhancement" }
    @{ Title = "Replace inline styles with a stylesheet";          Label = "refactor" }
    @{ Title = "Return 401 instead of 500 for expired tokens";     Label = "bug" }
    @{ Title = "Document the auth endpoints";                      Label = "documentation" }
    @{ Title = "Add request id to error responses";                Label = "enhancement" }
    @{ Title = "Timeout external identity provider calls";         Label = "bug" }
    @{ Title = "Validate email format server side";                Label = "bug" }
    @{ Title = "Add CI workflow for pull requests";                Label = "enhancement" }
    @{ Title = "Pin Node version in CI";                           Label = "enhancement" }
    @{ Title = "Enable dependency alerts";                         Label = "enhancement" }
    @{ Title = "Staging environment missing environment variables"; Label = "bug" }
    @{ Title = "Archive stale board items automatically";          Label = "enhancement" }
    @{ Title = "Document the issue template selection";            Label = "documentation" }
    @{ Title = "Add contributing guide";                           Label = "documentation" }
)

$labels = @(
    @{ Name = "bug";           Color = "d73a4a"; Description = "Something is not working" }
    @{ Name = "enhancement";   Color = "a2eeef"; Description = "New capability or improvement" }
    @{ Name = "documentation"; Color = "0075ca"; Description = "Documentation only" }
    @{ Name = "refactor";      Color = "6f42c1"; Description = "No behavior change" }
)

Write-Host "`nLabels" -ForegroundColor Cyan
foreach ($label in $labels) {
    if ($DryRun) {
        Write-Host "  [dry-run] label $($label.Name)" -ForegroundColor DarkGray
        continue
    }
    gh label create $label.Name --color $label.Color --description $label.Description --force | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $($label.Name)" -ForegroundColor Green
    } else {
        Write-Host "  WARN: could not create label $($label.Name)" -ForegroundColor Yellow
    }
}

Write-Host "`nIssues ($($backlog.Count))" -ForegroundColor Cyan
$created = @()
$index = 0

foreach ($item in $backlog) {
    $issueArgs = @(
        "issue", "create",
        "--title", $item.Title,
        "--body", "Seeded for the presentation demo."
    )
    if ($item.Label) { $issueArgs += @("--label", $item.Label) }

    if ($Assignees.Count -gt 0) {
        $assignee = $Assignees[$index % $Assignees.Count]
        $issueArgs += @("--assignee", $assignee)
    }

    if ($DryRun) {
        Write-Host "  [dry-run] $($item.Title)" -ForegroundColor DarkGray
        $index++
        continue
    }

    $url = gh @issueArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  FAIL: $($item.Title)" -ForegroundColor Yellow
        $index++
        continue
    }

    if ($url -match "/issues/(\d+)$") {
        $created += [int]$Matches[1]
        Write-Host "  #$($Matches[1]) $($item.Title)" -ForegroundColor Green
    } else {
        Write-Host "  $($item.Title)" -ForegroundColor Green
    }
    $index++
}

# ---------------------------------------------------------------- close some

if ($CloseCount -gt 0 -and $created.Count -gt 0 -and -not $DryRun) {
    $toClose = $created | Select-Object -First $CloseCount
    Write-Host "`nClosing $($toClose.Count) issues" -ForegroundColor Cyan

    foreach ($n in $toClose) {
        gh issue close $n --comment "Fixed and verified." | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  closed #$n" -ForegroundColor Green
        } else {
            Write-Host "  WARN: could not close #$n" -ForegroundColor Yellow
        }
    }
}

Write-Host @"

--------------------------------------------------------------------------
Done. Now verify the presentation actually works:

  ./scripts/preflight.ps1

Remember: a closed issue only moves its card to Done if the project has the
"Item closed" workflow enabled AND the item was already on the board.
--------------------------------------------------------------------------

"@ -ForegroundColor Yellow
