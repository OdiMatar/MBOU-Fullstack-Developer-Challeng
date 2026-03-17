@echo off
echo ========================================
echo  Hot Reload - Update de app
echo ========================================
echo.

cd app
echo r | flutter attach -d emulator-5554

echo.
echo Klaar!
pause
