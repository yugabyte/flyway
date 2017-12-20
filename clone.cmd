@echo off

setlocal

SET CURRENT_DIR=%cd%

echo ============== CLONE START

echo ============== CLEANING
call clean.cmd || goto :error

echo ============== CLONING MASTER
git clone https://github.com/boxfuse/flyway-master.git || goto :error
echo ============== CLONING OSSIFIER
git clone https://github.com/boxfuse/flyway-ossifier.git || goto :error

echo ============== CLONE SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== CLONE FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%
