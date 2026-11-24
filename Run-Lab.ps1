param([string]$ToolsDirectory = "$env:LOCALAPPDATA\ui-lab-tools")
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$python = "$root\robot\.venv\Scripts\python.exe"
if (-not (Test-Path -LiteralPath $python)) { throw 'Run Setup.ps1 first.' }
if (-not $env:CHROMEDRIVER) { $env:CHROMEDRIVER = [Environment]::GetEnvironmentVariable('CHROMEDRIVER', 'User') }
if (-not $env:CHROMEDRIVER -or -not (Test-Path -LiteralPath $env:CHROMEDRIVER)) { throw 'CHROMEDRIVER is missing. Run Setup.ps1.' }
$nodeMarker = Join-Path $ToolsDirectory 'node-directory.txt'
if (Test-Path -LiteralPath $nodeMarker) { $env:PATH = "$(Get-Content -LiteralPath $nodeMarker -Raw);$env:PATH".Replace("`r", '').Replace("`n", '') }
if (-not (Test-Path "$root\cypress\node_modules\.bin\cypress.cmd")) { throw 'Cypress is missing. Run Setup.ps1.' }
$batch = Get-Date -Format 'yyyyMMdd-HHmmss'
$evidence = Join-Path $root "evidence\$batch"
New-Item -ItemType Directory -Path $evidence -Force | Out-Null
Start-Transcript -Path "$evidence\console.txt"
function Assert-Exit([string]$Step) { if ($LASTEXITCODE -ne 0) { throw "$Step failed. See evidence in $evidence." } }
try {
    & $python -m robot --version
    & $env:CHROMEDRIVER --version
    node --version
    Push-Location "$root\robot"
    try {
        & $python -m robot -d "$evidence\robot-title-correct" -v BROWSER:headlesschrome first.robot
        Assert-Exit 'Robot first test'
        & $python -m robot -d "$evidence\robot-title-wrong" -v BROWSER:headlesschrome -v 'EXPECTED_TITLE:Web Form' first.robot
        if ($LASTEXITCODE -ne 1) { throw 'Expected exactly one intentional Robot title failure.' }
        & $python -m robot -d "$evidence\robot-form" -v BROWSER:headlesschrome first.robot web_form.robot
        Assert-Exit 'Robot restored title and web form'
        # Exactly two QP-01 evidence runs; no continuous or automatic retry loop.
        foreach ($run in @('run1','run2')) {
            $out = "results\$run"
            if (Test-Path $out) { Copy-Item -LiteralPath $out -Destination "$evidence\previous-robot-$run" -Recurse }
            & $python -m robot -d $out -v BROWSER:headlesschrome pizza_scenario.robot
            Assert-Exit "Robot $run"
        }
    } finally { Pop-Location }
    Push-Location "$root\cypress"
    try {
        & '.\node_modules\.bin\cypress.cmd' version
        $spec = Join-Path $root 'cypress\cypress\e2e\web-form.cy.js'
        $original = [IO.File]::ReadAllText($spec)
        try {
            [IO.File]::WriteAllText($spec, $original.Replace("should('eq', 'Web form')", "should('eq', 'Web Form')"))
            $env:LAB_RUN = "$batch-title-wrong"
            & '.\node_modules\.bin\cypress.cmd' run --browser chrome --spec cypress/e2e/web-form.cy.js --posix-exit-codes
            if ($LASTEXITCODE -ne 1) { throw 'Expected an intentional Cypress title failure.' }
            Copy-Item 'cypress\screenshots' "$evidence\cypress-title-wrong" -Recurse -ErrorAction SilentlyContinue
        } finally { [IO.File]::WriteAllText($spec, $original) }
        foreach ($run in @('run1','run2')) {
            $env:LAB_RUN = "$batch-$run"
            & '.\node_modules\.bin\cypress.cmd' run --browser chrome
            Assert-Exit "Cypress $run"
            Copy-Item 'cypress\screenshots' "$evidence\cypress-$run-screenshots" -Recurse
            Copy-Item 'cypress\videos' "$evidence\cypress-$run-videos" -Recurse
        }
    } finally { Pop-Location }
    Write-Host 'Automated runs finished. Complete the manual QP-01 run and update RESULTS.md from these real logs before submitting.'
} finally { Stop-Transcript }
