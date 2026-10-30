param(
  [string[]]$MySqlArguments = @()
)

$ErrorActionPreference = 'Stop'

$installDirectory = Join-Path $env:LOCALAPPDATA 'Programs\MySQL\MySQL Server 8.4'
$configDirectory = Join-Path $env:LOCALAPPDATA 'MySQL\proyecto_bd'
$clientPath = Join-Path $installDirectory 'bin\mysql.exe'
$clientConfigPath = Join-Path $configDirectory 'inventario-client.ini'

if (-not (Test-Path $clientPath)) {
  throw "No se encontró el cliente MySQL: $clientPath"
}
if (-not (Test-Path $clientConfigPath)) {
  throw "No se encontró la configuración local de conexión: $clientConfigPath"
}

& $clientPath "--defaults-extra-file=$clientConfigPath" '--database=inventario' @MySqlArguments
if ($LASTEXITCODE -ne 0) {
  throw "La conexión a inventario falló (código $LASTEXITCODE)."
}
