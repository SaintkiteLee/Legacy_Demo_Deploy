@echo off
echo =========================================
echo       Restarting Docker Containers
echo =========================================
docker-compose down
echo.
docker-compose up -d
echo.
echo Services have been restarted.
pause
