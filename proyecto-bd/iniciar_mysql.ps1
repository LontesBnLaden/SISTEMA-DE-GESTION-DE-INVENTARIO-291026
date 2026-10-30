$ErrorActionPreference = 'Stop'

$installDirectory = Join-Path $env:LOCALAPPDATA 'Programs\MySQL\MySQL Server 8.4'
$configDirectory = Join-Path $env:LOCALAPPDATA 'MySQL\proyecto_bd'
$serverPath = Join-Path $installDirectory 'bin\mysqld.exe'
$configPath = Join-Path $configDirectory 'my.ini'
$port = 3306

function Test-MySqlPort {
  $connection = New-Object System.Net.Sockets.TcpClient
  try {
    $attempt = $connection.ConnectAsync('127.0.0.1', $port)
    if (-not $attempt.Wait(500)) {
      return $false
    }
    return $connection.Connected
  } catch {
    return $false
  } finally {
    $connection.Dispose()
  }
}

if (-not (Test-Path $serverPath)) {
  throw "No se encontró MySQL Server: $serverPath"
}
if (-not (Test-Path $configPath)) {
  throw "No se encontró la configuración de MySQL: $configPath"
}

$mysqlProcesses = Get-CimInstance Win32_Process -Filter "Name = 'mysqld.exe'" |
  Where-Object { $_.ExecutablePath -eq $serverPath }
if (Test-MySqlPort) {
  if ($mysqlProcesses) {
    Write-Host "MySQL ya está iniciado en 127.0.0.1:$port."
    exit 0
  }
  throw "El puerto $port ya está ocupado por otro proceso."
}
if ($mysqlProcesses) {
  throw "Ya existe un proceso MySQL, pero no acepta conexiones. Revisa $configDirectory."
}

$logPath = Join-Path $configDirectory 'mysql-console.log'
$server = Start-Process -FilePath $serverPath `
  -ArgumentList @("--defaults-file=$configPath", '--console') `
  -WorkingDirectory $installDirectory `
  -WindowStyle Hidden `
  -RedirectStandardOutput $logPath `
  -RedirectStandardError (Join-Path $configDirectory 'mysql-stderr.log') `
  -PassThru

$deadline = (Get-Date).AddSeconds(45)
do {
  Start-Sleep -Milliseconds 500
  if (Test-MySqlPort) {
    $mysqlProcesses = Get-CimInstance Win32_Process -Filter "Name = 'mysqld.exe'" |
      Where-Object { $_.ExecutablePath -eq $serverPath }
    if ($mysqlProcesses) {
      Write-Host "MySQL está listo en 127.0.0.1:$port (PID $($server.Id))."
      exit 0
    }
    throw "El puerto $port fue ocupado por otro proceso."
  }
} while ((Get-Date) -lt $deadline)

$errorLog = Join-Path $configDirectory 'mysql-error.log'
$log = if (Test-Path $errorLog) { Get-Content $errorLog -Raw } else { 'No se generó un registro de error.' }
throw "MySQL no pudo iniciar. Registro: $log"
