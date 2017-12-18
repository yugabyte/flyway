@echo off

setlocal

SET CURRENT_DIR=%cd%

echo ============== CLONE START

echo ============== CLEANING
call clean.cmd || goto :error

echo ============== CLONING MASTER
git clone https://github.com/boxfuse/flyway-master.git --depth=1 || goto :error
echo ============== CLONING OSSIFIER
git clone https://github.com/boxfuse/flyway-ossifier.git --depth=1 || goto :error

echo ============== CLONE SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
echo ============== CLONE FAILED WITH ERROR %errorlevel%
cd "%CURRENT_DIR%"
pause
exit /b %errorlevel%
