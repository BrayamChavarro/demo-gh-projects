<#
.SYNOPSIS
    Verifies that everything the live demo depends on is actually in place.

.DESCRIPTION
    Run this 15 minutes before the presentation. Every check maps to a step in
    docs/DEMO.md that fails visibly on stage when its condition is not met.

.EXAMPLE
    ./scripts/preflight.ps1
#>
[CmdletBinding()]
param(
    [string]$Owner = "@me"
)

$ErrorActionPreference = "Continue"

$pass = 0
$warn = 0
$fail = 0

function Ok([string]$Message) {
    Write-Host "  [ OK ]  $Message" -ForegroundColor Green
    $script:pass++
}

function Warn([string]$Message) {
    Write-Host "  [WARN]  $Message" -ForegroundColor Yellow
    $script:warn++
}

function Bad([string]$Message) {
    Write-Host "  [FAIL]  $Message" -ForegroundColor Red
    $script:fail++
}

Write-Host "`nPreflight`n" -ForegroundColor Cyan

# ---------------------------------------------------------------- tooling

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Bad "gh is not installed. https://cli.github.com"
    exit 1
}
Ok "gh is installed"

gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) {
    Bad "gh is not authenticated. Run: gh auth login"
    exit 1
}
Ok "gh is authenticated"

# ---------------------------------------------------------------- repository

$repo = gh repo view --json nameWithOwner -q .nameWithOwner
if ($LASTEXITCODE -ne 0 -or -not $repo) {
    Bad "Not inside a GitHub repository. Run from the repo root."
    exit 1
}
Ok "repository: $repo"

$templates = @(
    ".github/ISSUE_TEMPLATE/bug_report.yml",
    ".github/ISSUE_TEMPLATE/feature_request.yml",
    ".github/ISSUE_TEMPLATE/config.yml"
)
$missing = @($templates | Where-Object { -not (Test-Path $_) })
if ($missing.Count -eq 0) {
    Ok "issue templates present in the working tree"
} else {
    Bad "missing locally: $($missing -join ', ')"
}

$remote = gh api "repos/$repo/contents/.github/ISSUE_TEMPLATE" --jq ".[].name" 2>$null
if ($LASTEXITCODE -eq 0 -and $remote) {
    Ok "issue templates present on the default branch"
} else {
    Bad "templates not found on the default branch. The form menu will be empty on GitHub."
}

# ---------------------------------------------------------------- issues

$issues = gh issue list --state all --limit 200 --json number,state,assignees | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) {
    Bad "could not list issues"
    exit 1
}

$total = @($issues).Count
$open = @($issues | Where-Object { $_.state -eq "OPEN" }).Count
$closed = $total - $open

if ($total -ge 20) {
    Ok "issues: $total total ($open open, $closed closed)"
} elseif ($total -gt 0) {
    Warn "only $total issues. Insights will look flat. Aim for 20 or more."
} else {
    Bad "no issues. The board and every chart will be empty."
}

$assignees = @(
    $issues |
        Where-Object { $_.state -eq "OPEN" } |
        ForEach-Object { $_.assignees } |
        ForEach-Object { $_.login } |
        Sort-Object -Unique
)

if ($assignees.Count -ge 2) {
    Ok "open issues assigned to $($assignees.Count) people: $($assignees -join ', ')"
} elseif ($assignees.Count -eq 1) {
    Warn "only one assignee ($($assignees[0])). The workload chart will show a single column."
} else {
    Bad "no assignees. The Insights chart grouped by assignee will be empty."
}

if ($closed -ge 3) {
    Ok "$closed closed issues, the Done column has content"
} else {
    Warn "only $closed closed issues. Done and Burn up will look empty."
}

# ---------------------------------------------------------------- projects

$projectsJson = gh project list --owner $Owner --format json 2>$null
if ($LASTEXITCODE -eq 0 -and $projectsJson) {
    $projects = @(($projectsJson | ConvertFrom-Json).projects)
    if ($projects.Count -gt 0) {
        Ok "$($projects.Count) project(s) for $Owner"
        foreach ($p in $projects) {
            Write-Host "          #$($p.number)  $($p.title)" -ForegroundColor DarkGray
        }
        Warn "automatic checks stop here: linked repository, workflows and views need a visual check"
    } else {
        Bad "no projects for $Owner. Run ./scripts/setup-project.ps1"
    }
} else {
    Warn "could not list projects. Check the token scope: gh auth refresh -s project"
}

# ---------------------------------------------------------------- summary

Write-Host "`nManual checks that no script can perform:`n" -ForegroundColor Cyan
Write-Host "  1. Project is linked to $repo                (repo -> Projects tab)" -ForegroundColor DarkGray
Write-Host "  2. Workflow 'Auto-add to project' enabled    (board -> ... -> Workflows)" -ForegroundColor DarkGray
Write-Host "  3. Workflow 'Item closed' enabled            (sets status to Done)" -ForegroundColor DarkGray
Write-Host "  4. Board view exists and is grouped by Status" -ForegroundColor DarkGray
Write-Host "  5. Insights chart by Assignee renders data" -ForegroundColor DarkGray
Write-Host "  6. Browser session is signed in to GitHub`n" -ForegroundColor DarkGray

$color = if ($fail -gt 0) { "Red" } elseif ($warn -gt 0) { "Yellow" } else { "Green" }
Write-Host "Result: $pass ok, $warn warnings, $fail failures`n" -ForegroundColor $color

if ($fail -gt 0) { exit 1 }
