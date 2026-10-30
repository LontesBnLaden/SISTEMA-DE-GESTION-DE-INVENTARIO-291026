$ErrorActionPreference = 'Stop'

$installDirectory = Join-Path $env:LOCALAPPDATA 'Programs\MySQL\MySQL Server 8.4'
$configDirectory = Join-Path $env:LOCALAPPDATA 'MySQL\proyecto_bd'
$clientPath = Join-Path $installDirectory 'bin\mysql.exe'
$clientConfigPath = Join-Path $configDirectory 'inventario-client.ini'
$seedPath = Join-Path $PSScriptRoot 'cargar_datos_demo.sql'
$presentationQueryPath = Join-Path $PSScriptRoot 'consultas_presentacion.sql'

foreach ($requiredPath in @($clientPath, $clientConfigPath, $seedPath, $presentationQueryPath)) {
  if (-not (Test-Path -LiteralPath $requiredPath)) {
    throw "No se encontró un archivo necesario: $requiredPath"
  }
}

$seedSource = $seedPath.Replace('\', '/')
& $clientPath "--defaults-extra-file=$clientConfigPath" '--database=inventario' '--batch' '--raw' "--execute=SOURCE $seedSource"
if ($LASTEXITCODE -ne 0) {
  throw "No se pudieron cargar los datos de demostración (código $LASTEXITCODE)."
}

Write-Host "`nDatos de demostracion cargados. Resultado para presentar:`n"
$presentationSource = $presentationQueryPath.Replace('\', '/')
& $clientPath "--defaults-extra-file=$clientConfigPath" '--database=inventario' '--table' "--execute=SOURCE $presentationSource"
if ($LASTEXITCODE -ne 0) {
  throw "No se pudieron ejecutar las consultas de presentación (código $LASTEXITCODE)."
}
