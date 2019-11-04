param (
  [ValidateSet("community", "pro", "enterprise")]
  [Parameter(Mandatory=$true)]
  [string]
  $Edition
)

$ErrorActionPreference = "Stop"

Write-Output "Looking for Flyway $Edition Zip";
$flywayZip = (Get-ChildItem -Filter "$Edition\flyway-commandline-*-windows-x64.zip")[0].Name;

$unzipLocation = (Get-Location).Path + "\unzip";
$unzipLocationExists = Test-Path $unzipLocation;

if ($unzipLocationExists) {
  Write-Output "Deleting $unzipLocation";
  Remove-Item -Path $unzipLocation -Recurse;
}

Write-Output "Creating $unzipLocation";
New-Item -ItemType directory -Path $unzipLocation;

Write-Output "Expanding $flywayZip to $unzipLocation\$Edition"
Expand-Archive -LiteralPath "$Edition\$flywayZip" -DestinationPath "$unzipLocation\$Edition";

Write-Output "Looking for Flyway root directory"
$flywayRootDirectory = (Get-ChildItem "$unzipLocation\$Edition" -Filter "flyway-*")[0].Name;
$flywayCmd = "$unzipLocation\$Edition\$flywayRootDirectory\flyway.cmd";

Write-Output "Beginning smoke tests"
Write-Output "Smoke testing Flyway $Edition"

function Invoke-Flyway($command) {
  & $flywayCmd @("-configFiles=smoke-tests\flyway.conf", $command, "-$Edition");
}

Invoke-Flyway "info";
Invoke-Flyway "migrate";
Invoke-Flyway "validate";
Invoke-Flyway "info";
if ($Edition -ne "community" ) {
  Invoke-Flyway "undo";
  Invoke-Flyway "info";
}
Invoke-Flyway "clean";

Write-Output "Smoke testing JSON output"
$infoJson = & $flywayCmd @("-configFiles=smoke-tests\flyway.conf", "-json.experimental", "info") | out-string

Write-Output $infoJson;

$parsedInfoJson = ConvertFrom-Json $infoJson;

if ($null -ne $parsedInfoJson.Error.message) {
  throw 'Error detected in JSON output';
}
