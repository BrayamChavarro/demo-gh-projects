<#
.SYNOPSIS
    Creates and configures a GitHub Projects v2 board for this repository.

.DESCRIPTION
    Automates the part of the setup that the GitHub CLI actually supports:
      - creates the project
      - links it to the repository
      - creates the custom fields the presentation uses

    Two things are NOT automatable and are printed as manual steps at the end:
    built-in project workflows and saved views. The CLI exposes no command for
    either, and GitHub ships no API for them.

.EXAMPLE
    ./scripts/setup-project.ps1

.EXAMPLE
    ./scripts/setup-project.ps1 -Owner my-org -Title "Demo Board"
#>
[CmdletBinding()]
param(
    [string]$Owner = "@me",
    [string]$Title = "Demo Board",
    [string]$Repo
)

$ErrorActionPreference = "Continue"

function Fail([string]$Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Fail "GitHub CLI not found. Install it from https://cli.github.com"
}

gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) {
    Fail "gh is not authenticated. Run: gh auth login"
}

if (-not $Repo) {
    $Repo = gh repo view --json nameWithOwner -q .nameWithOwner
    if ($LASTEXITCODE -ne 0 -or -not $Repo) {
        Fail "Not inside a GitHub repository. Run from the repo root or pass -Repo owner/name"
    }
}
Write-Host "Repository : $Repo" -ForegroundColor Cyan

# ---------------------------------------------------------------- create project

Write-Host "`nCreating project `"$Title`"..." -ForegroundColor Cyan
$raw = gh project create --owner $Owner --title $Title --format json
if ($LASTEXITCODE -ne 0) { Fail "Could not create the project." }

$project = $raw | ConvertFrom-Json
$number = $project.number
if (-not $number) { Fail "Could not read the new project number from the CLI output." }

Write-Host "Project #$number created." -ForegroundColor Green

# ---------------------------------------------------------------- link repository

Write-Host "`nLinking project #$number to $Repo..." -ForegroundColor Cyan
gh project link $number --owner $Owner --repo $Repo | Out-Null
if ($LASTEXITCODE -ne 0) {
    Fail "Could not link the project to the repository. Check that you have admin rights on $Repo."
}

# ---------------------------------------------------------------- custom fields
# A project created from the CLI starts with only the Title field. The Status
# field that the Board template would create does not exist, so it is created here.

function Get-FieldNames([int]$Number) {
    $json = gh project field-list $Number --owner $Owner --format json
    if ($LASTEXITCODE -ne 0) { Fail "Could not list fields for project $Number." }
    return @(($json | ConvertFrom-Json).fields | ForEach-Object { $_.name })
}

$existing = Get-FieldNames $number

$fields = @(
    @{ Name = "Status";   Type = "SINGLE_SELECT"; Options = "Todo,In Progress,Done" }
    @{ Name = "Priority"; Type = "SINGLE_SELECT"; Options = "Low,Medium,High" }
    @{ Name = "Size";     Type = "SINGLE_SELECT"; Options = "XS,S,M,L,XL" }
)

foreach ($field in $fields) {
    if ($existing -contains $field.Name) {
        Write-Host "Field $($field.Name) already exists, skipped." -ForegroundColor DarkGray
        continue
    }

    $fieldArgs = @(
        "project", "field-create", "$number",
        "--owner", $Owner,
        "--name", $field.Name,
        "--data-type", $field.Type
    )
    if ($field.Options) {
        $fieldArgs += @("--single-select-options", $field.Options)
    }

    gh @fieldArgs | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARN: could not create field $($field.Name)." -ForegroundColor Yellow
    } else {
        Write-Host "Field $($field.Name) created." -ForegroundColor Green
    }
}

# ---------------------------------------------------------------- manual steps

$url = "https://github.com/users/" + ($Owner -replace "^@", "") + "/projects/$number"
if ($Owner -ne "@me") {
    $url = "https://github.com/orgs/$Owner/projects/$number"
}

Write-Host @"

--------------------------------------------------------------------------
Project  : #$number
URL      : $url

Next steps, manual by design. The CLI cannot do them:

  1. Open the project and create the views you want to show
     (Board grouped by Status, then Roadmap).

  2. ... menu  ->  Workflows  ->  enable BOTH:
       * Auto-add to project     (filter: repository = $Repo)
       * Item closed             (Set status to Done)

     These are independent. Enabling only the second one produces no visible
     effect, because items never reach the board in the first place.

  3. Insights  ->  New chart
       Layout: Column | X-axis: Assignee | Group by: Status
     This chart is only useful once the issues have assignees.

Then run:  ./scripts/seed-issues.ps1
--------------------------------------------------------------------------

"@ -ForegroundColor Yellow
