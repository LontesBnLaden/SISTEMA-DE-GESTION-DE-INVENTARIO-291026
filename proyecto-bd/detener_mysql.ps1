$ErrorActionPreference = 'Stop'

$installDirectory = Join-Path $env:LOCALAPPDATA 'Programs\MySQL\MySQL Server 8.4'
$configDirectory = Join-Path $env:LOCALAPPDATA 'MySQL\proyecto_bd'
$adminPath = Join-Path $installDirectory 'bin\mysqladmin.exe'
$clientConfigPath = Join-Path $configDirectory 'root-client.ini'

if (-not (Test-Path $adminPath)) {
  throw "No se encontró mysqladmin: $adminPath"
}
if (-not (Test-Path $clientConfigPath)) {
  throw "No se encontró la configuración local de conexión: $clientConfigPath"
}

& $adminPath "--defaults-extra-file=$clientConfigPath" shutdown
if ($LASTEXITCODE -ne 0) {
  throw "No se pudo detener MySQL (código $LASTEXITCODE)."
}

Write-Host 'MySQL se detuvo correctamente.'
