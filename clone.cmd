@echo off

if [%1]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%1
)

setlocal

SET CURRENT_DIR=%cd%

echo ============== CLONE START

echo ============== CLEANING
call clean.cmd || goto :error

echo ============== CLONING MASTER (Git Branch: %FLYWAY_BRANCH%)
git clone -b %FLYWAY_BRANCH% git@github.com:flyway/flyway-master.git || goto :error
echo ============== CLONING OSSIFIER
git clone git@github.com:flyway/flyway-ossifier.git || goto :error

echo ============== CLONE SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== CLONE FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%
