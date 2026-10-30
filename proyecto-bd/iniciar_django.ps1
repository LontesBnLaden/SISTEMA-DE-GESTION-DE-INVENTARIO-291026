$ErrorActionPreference = 'Stop'

$venvPython = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
$managePy = Join-Path $PSScriptRoot 'manage.py'

if (-not (Test-Path -LiteralPath $venvPython)) {
  throw 'No existe el entorno virtual. Ejecuta primero .\configurar_django.ps1.'
}
if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot '.env'))) {
  throw 'No existe .env. Ejecuta primero .\configurar_django.ps1.'
}

$previousDebug = $env:DJANGO_DEBUG
$env:DJANGO_DEBUG = 'True'
try {
  & $venvPython $managePy runserver 127.0.0.1:8000
  if ($LASTEXITCODE -ne 0) {
    throw "Django finalizó con error (código $LASTEXITCODE)."
  }
}
finally {
  if ($null -eq $previousDebug) {
    Remove-Item Env:DJANGO_DEBUG -ErrorAction SilentlyContinue
  }
  else {
    $env:DJANGO_DEBUG = $previousDebug
  }
}
