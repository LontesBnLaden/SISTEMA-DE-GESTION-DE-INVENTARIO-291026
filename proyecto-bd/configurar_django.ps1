$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$venvPython = Join-Path $projectRoot '.venv\Scripts\python.exe'
$requirementsPath = Join-Path $projectRoot 'requirements.txt'
$envPath = Join-Path $projectRoot '.env'
$mysqlConfigPath = Join-Path $env:LOCALAPPDATA 'MySQL\proyecto_bd\inventario-client.ini'

if (-not (Test-Path -LiteralPath $requirementsPath)) {
  throw "No se encontró requirements.txt en $projectRoot."
}

if (-not (Test-Path -LiteralPath $mysqlConfigPath)) {
  throw "No se encontró la conexión MySQL local: $mysqlConfigPath"
}

if (-not (Test-Path -LiteralPath $venvPython)) {
  $python = Get-Command python -ErrorAction Stop
  & $python.Source -m venv (Join-Path $projectRoot '.venv')
  if ($LASTEXITCODE -ne 0) {
    throw "No se pudo crear el entorno virtual (código $LASTEXITCODE)."
  }
}

if (-not (Test-Path -LiteralPath $envPath)) {
  $mysqlSettings = @{}
  $inClientSection = $false
  foreach ($line in Get-Content -LiteralPath $mysqlConfigPath) {
    if ($line -match '^\s*\[(.+)\]\s*$') {
      $inClientSection = $Matches[1] -eq 'client'
      continue
    }
    if ($inClientSection -and $line -match '^\s*([^=]+?)\s*=\s*(.*)$') {
      $mysqlSettings[$Matches[1].Trim().ToLowerInvariant()] = $Matches[2].Trim()
    }
  }

  foreach ($key in @('user', 'password', 'host', 'port', 'database')) {
    if (-not $mysqlSettings.ContainsKey($key)) {
      throw "Falta la opción '$key' en la sección [client] de $mysqlConfigPath."
    }
  }

  $secretBytes = New-Object byte[] 64
  $randomGenerator = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  $randomGenerator.GetBytes($secretBytes)
  $randomGenerator.Dispose()
  $secretKey = [Convert]::ToBase64String($secretBytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
  $passwordBytes = [System.Text.Encoding]::UTF8.GetBytes($mysqlSettings['password'])
  $passwordBase64 = [Convert]::ToBase64String($passwordBytes)
  $envLines = @(
    "DJANGO_SECRET_KEY=$secretKey"
    'DJANGO_DEBUG=False'
    'DJANGO_ALLOWED_HOSTS=127.0.0.1,localhost'
    "DB_NAME=$($mysqlSettings['database'])"
    "DB_USER=$($mysqlSettings['user'])"
    "DB_PASSWORD_B64=$passwordBase64"
    "DB_HOST=$($mysqlSettings['host'])"
    "DB_PORT=$($mysqlSettings['port'])"
  )
  [System.IO.File]::WriteAllLines(
    $envPath,
    [string[]]$envLines,
    (New-Object System.Text.UTF8Encoding($false))
  )
}

& $venvPython -m pip install -r $requirementsPath
if ($LASTEXITCODE -ne 0) {
  throw "No se pudieron instalar las dependencias Python (código $LASTEXITCODE)."
}

& $venvPython (Join-Path $projectRoot 'manage.py') check --database default
if ($LASTEXITCODE -ne 0) {
  throw "Django detectó errores o no pudo verificar la conexión a MySQL (código $LASTEXITCODE)."
}

Write-Host 'Entorno virtual, dependencias y conexión Django-MySQL configurados correctamente.'
Write-Host "Activa el entorno con: .\.venv\Scripts\Activate.ps1"
Write-Host 'Luego inicia la aplicación con: .\iniciar_django.ps1'
