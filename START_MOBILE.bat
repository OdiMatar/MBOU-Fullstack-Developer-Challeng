@echo off
setlocal

echo ========================================
echo  Developer Challenge - Mobile Start
echo ========================================
echo.

if "%~1"=="" (
  echo Gebruik: START_MOBILE.bat ^<JOUW_PC_IP^> [DEVICE_ID]
  echo Voorbeeld: START_MOBILE.bat 10.32.99.66 R9WN123ABC
  echo.
  echo Tip: check je IP met:
  echo   ipconfig ^| findstr /R /C:"IPv4 Address" /C:"IPv4-adres"
  exit /b 1
)

set API_HOST=%~1
set DEVICE_ARG=
if not "%~2"=="" set DEVICE_ARG=-d %~2

echo [1/2] Laravel API starten op alle netwerkinterfaces...
start "Laravel API (Mobile)" cmd /k "cd backend && php artisan serve --host=0.0.0.0 --port=8000"
timeout /t 3 /nobreak >nul

echo [2/2] Flutter app starten met API_HOST=%API_HOST%...
start "Flutter App (Mobile)" cmd /k "cd app && flutter run %DEVICE_ARG% --dart-define=API_HOST=%API_HOST%"

echo.
echo Klaar! Zorg dat telefoon en laptop op hetzelfde netwerk zitten.
echo API host voor mobiel: %API_HOST%
echo.
