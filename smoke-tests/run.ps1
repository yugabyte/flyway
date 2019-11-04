param (
  [ValidateSet("community", "pro", "enterprise")]
  [Parameter(Mandatory=$true)]
  [string]
  $Edition
)

$ErrorActionPreference = "Stop"

switch ($Edition) {
  "pro" { 
    $env:FLYWAY_LICENSE_KEY = "FL01556C7E3FF521CBEB7D7BA1D6EBE28989103EC8A5C62F8A4583EA1C0B7B9789BCBB2B31E8CA4A08CC1F9C5FC32784BC4C90D06673ECFBB452BF87AE43D347EC1A2DCF98821CC6C2EEF0C642CDDCF225DC3B26CCFF261D6C5AF890F699C66B96CB7482EF90DEF93257420F1BAEC981AF7CE20EE7738E8648CBD73866588C0E6BE82A35DC6504971B4119018FEEE69B14F01695CE3957460CE0161A2EF09B9D3AAC059ABDC0A0E5670955A7C4FA2DBC34A6181492AABC18CFFFACC855CFA5A2B3E3B88F916D20ABF565C9211ACBCC568B955B8418749A49B4A0F87EC1A99BCCEF01177C2B8C974F8D30C0E14957D605858EC99038950AB13D0152F24CF78E897779"
    break
   }
   "enterprise" {
    $env:FLYWAY_LICENSE_KEY = "FL014DC97E51F030E977C6AE53F8742A0BDCF0FFAD775BA4A6AB023D9FDF1ECF0E9362DD18C3FAB394A0CE4E169A3BA04BBD4EBDA7737D09B489AAD70044032D8041E63609CC43EC504EA476E09944988D85F9E70301C451582B7107FD13300AD7EF5871C39FEA3F52455C5068776D2B2A05A25357B9D38AA0C64681EE668DFA8A67E27A3D93BD051C9657B0CA3CDD0734B83367CDE1876DC175623FA8737E28FC1DEFF5135308485E9FD80F82705C1671DA1F35E52033D093C96EE40AEE0ED2E955828C06C8765F3FAD32DD51F11B3825F48BF4FE5B29F7F2AD6B530710762161D0915C12F9E4C9555268A6EAAB8B68D496E23F5165D0C47FFE745E7F383D1D848A"
   }
}

Write-Output "Looking for Flyway $Edition Zip"
$flywayZip = Resolve-Path "$Edition\flyway-commandline-*-windows-x64.zip"
$unzipLocation = Join-Path (Resolve-Path .) "unzip"

if (Test-Path $unzipLocation) {
  Write-Output "Deleting $unzipLocation"
  Remove-Item -Path $unzipLocation -Recurse
}

Write-Output "Creating $unzipLocation"
New-Item -ItemType directory -Path $unzipLocation

Write-Output "Expanding $flywayZip to $unzipLocation\$Edition"
Expand-Archive -LiteralPath "$flywayZip" -DestinationPath "$unzipLocation\$Edition"

$flywayCmd = Resolve-Path "$unzipLocation\$Edition\flyway-*\flyway.cmd"

function Invoke-Flyway($command) {
  & $flywayCmd @("-configFiles=smoke-tests\flyway.conf", $command, "-$Edition")
}

Write-Output "Smoke testing Flyway $Edition"

Invoke-Flyway "info"
Invoke-Flyway "migrate"
Invoke-Flyway "validate"
Invoke-Flyway "info"
if ($Edition -ne "community") {
  Invoke-Flyway "undo"
  Invoke-Flyway "info"
}
Invoke-Flyway "clean"

Write-Output "Smoke testing JSON output"
$infoJson = & $flywayCmd @("-configFiles=smoke-tests\flyway.conf", "-json.experimental", "info") | Out-String

Write-Output $infoJson

$parsedInfoJson = ConvertFrom-Json $infoJson

if ($null -ne $parsedInfoJson.Error.message) {
  throw 'Error detected in JSON output'
}
