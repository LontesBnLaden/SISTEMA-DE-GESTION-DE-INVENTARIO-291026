@echo off
setlocal

set "MYSQL_CLIENT=%LOCALAPPDATA%\Programs\MySQL\MySQL Server 8.4\bin\mysql.exe"
set "MYSQL_CONFIG=%LOCALAPPDATA%\MySQL\proyecto_bd\inventario-client.ini"

if not exist "%MYSQL_CLIENT%" (
  echo No se encontro el cliente MySQL: "%MYSQL_CLIENT%"
  exit /b 1
)

if not exist "%MYSQL_CONFIG%" (
  echo No se encontro la configuracion local: "%MYSQL_CONFIG%"
  exit /b 1
)

"%MYSQL_CLIENT%" --defaults-extra-file="%MYSQL_CONFIG%" --database=inventario %*
exit /b %ERRORLEVEL%
