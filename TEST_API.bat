@echo off
echo ========================================
echo  API Test Script
echo ========================================
echo.

echo Test 1: GET /api/items
curl -X GET http://localhost:8000/api/items
echo.
echo.

echo Test 2: POST /api/items
curl -X POST http://localhost:8000/api/items -H "Content-Type: application/json" -d "{\"name\":\"Test Item\",\"description\":\"Dit is een test\"}"
echo.
echo.

echo Druk op een toets om te sluiten...
pause >nul
