@echo off
echo ========================================
echo  Developer Challenge - Start Script
echo ========================================
echo.

echo [1/2] Laravel API starten...
start "Laravel API" cmd /k "cd backend && php artisan serve"
timeout /t 3 /nobreak >nul

echo [2/2] Klaar!
echo.
echo Laravel API draait op: http://localhost:8000
echo.
echo Om de Flutter app te starten:
echo 1. Open Android Studio emulator
echo 2. Run: cd app
echo 3. Run: flutter run
echo.
echo Druk op een toets om dit venster te sluiten...
pause >nul
