param([string]$ToolsDirectory = "$env:LOCALAPPDATA\ui-lab-tools")
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
New-Item -ItemType Directory -Path $ToolsDirectory -Force | Out-Null
function Check-Exit([string]$Step) {
    if ($LASTEXITCODE -ne 0) { throw "$Step failed with exit code $LASTEXITCODE" }
}
# Install portable Node only when npm is missing. No administrator rights needed.
if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
    $base = 'https://nodejs.org/dist/latest-v24.x'
    $sums = (Invoke-WebRequest "$base/SHASUMS256.txt" -UseBasicParsing).Content
    $line = ($sums -split "`n" | Where-Object { $_ -match 'node-v[\d.]+-win-x64.zip$' } | Select-Object -First 1).Trim()
    if (-not $line) { throw 'No Windows x64 Node release found.' }
    $parts = $line -split '\s+'
    $zip = Join-Path $ToolsDirectory $parts[1]
    Invoke-WebRequest "$base/$($parts[1])" -OutFile $zip
    if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne $parts[0]) { throw 'Node checksum mismatch.' }
    Expand-Archive -LiteralPath $zip -DestinationPath $ToolsDirectory -Force
    $nodeDir = Join-Path $ToolsDirectory ($parts[1] -replace '\.zip$', '')
    $env:PATH = "$nodeDir;$env:PATH"
    Set-Content -LiteralPath (Join-Path $ToolsDirectory 'node-directory.txt') -Value $nodeDir
}
node --version
npm.cmd --version
$chrome = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $chrome) { throw 'Install Google Chrome, then run Setup.ps1 again.' }
$version = (Get-Item -LiteralPath $chrome).VersionInfo.ProductVersion
$build = (($version -split '\.')[0..2] -join '.')
$metadata = Invoke-RestMethod 'https://googlechromelabs.github.io/chrome-for-testing/latest-patch-versions-per-build-with-downloads.json'
$entry = $metadata.builds.$build
if (-not $entry) { throw "No matching ChromeDriver build for Chrome $version. Check Chrome for Testing." }
$download = $entry.downloads.chromedriver | Where-Object platform -eq 'win64' | Select-Object -First 1
$driverZip = Join-Path $ToolsDirectory 'chromedriver-win64.zip'
Invoke-WebRequest $download.url -OutFile $driverZip
Expand-Archive -LiteralPath $driverZip -DestinationPath $ToolsDirectory -Force
$env:CHROMEDRIVER = Join-Path $ToolsDirectory 'chromedriver-win64\chromedriver.exe'
[Environment]::SetEnvironmentVariable('CHROMEDRIVER', $env:CHROMEDRIVER, 'User')
& $env:CHROMEDRIVER --version
Check-Exit 'ChromeDriver verification'
python -m venv "$root\robot\.venv"
Check-Exit 'Python virtual environment creation'
& "$root\robot\.venv\Scripts\python.exe" -m pip install -r "$root\robot\requirements.txt"
Check-Exit 'Robot Framework installation'
Push-Location "$root\cypress"
try {
    npm.cmd install
    Check-Exit 'Cypress installation'
    & '.\node_modules\.bin\cypress.cmd' verify
    Check-Exit 'Cypress verification'
} finally { Pop-Location }
Write-Host 'Setup complete. Run .\Run-Lab.ps1 to collect evidence.'
