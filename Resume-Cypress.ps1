$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$marker = "$env:LOCALAPPDATA\ui-lab-tools\node-directory.txt"
if (Test-Path -LiteralPath $marker) {
    $nodeDirectory = (Get-Content -LiteralPath $marker -Raw).Trim()
    $env:PATH = "$nodeDirectory;$env:PATH"
}
$batch = Get-Date -Format 'yyyyMMdd-HHmmss'
$evidence = Join-Path $root "evidence\$batch-cypress-resume"
New-Item -ItemType Directory -Path $evidence -Force | Out-Null
Start-Transcript -Path "$evidence\console.txt"
Push-Location "$root\cypress"
try {
    # Preserve the successful pizza evidence from the interrupted run.
    foreach ($folder in @('screenshots', 'videos')) {
        if (Test-Path "cypress\$folder") {
            Copy-Item "cypress\$folder" "$evidence\previous-$folder" -Recurse
        }
    }
    npm.cmd install --save-dev --save-exact cypress@16.3.0
    if ($LASTEXITCODE -ne 0) { throw 'Cypress upgrade failed. Send the error text.' }
    & '.\node_modules\.bin\cypress.cmd' verify
    if ($LASTEXITCODE -ne 0) { throw 'Cypress verification failed.' }
    & '.\node_modules\.bin\cypress.cmd' version
    # Two required full runs, without repeating the completed Robot work.
    foreach ($run in @('run1', 'run2')) {
        $env:LAB_RUN = "$batch-resume-$run"
        & '.\node_modules\.bin\cypress.cmd' run --browser chrome
        if ($LASTEXITCODE -ne 0) { throw "Cypress $run failed. Send the error text." }
        Copy-Item 'cypress\screenshots' "$evidence\cypress-$run-screenshots" -Recurse
        Copy-Item 'cypress\videos' "$evidence\cypress-$run-videos" -Recurse
    }
    Write-Host 'CYPRESS COMPLETE: both full runs passed. Tell ChatGPT to review the saved results.'
} finally {
    Pop-Location
    Stop-Transcript
}
