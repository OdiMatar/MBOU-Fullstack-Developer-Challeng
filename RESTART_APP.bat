@echo off
echo ========================================
echo  App Herstarten
echo ========================================
echo.

echo [1/2] App stoppen...
taskkill /F /IM flutter.exe 2>nul

timeout /t 2 /nobreak >nul

echo [2/2] App starten...
start "Flutter App" cmd /k "cd app && flutter run -d emulator-5554"

echo.
echo App wordt herstart...
echo Check het andere venster voor de voortgang.
echo.
pause
