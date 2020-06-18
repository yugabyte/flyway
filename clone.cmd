@echo off

if [%1]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%1
)

if "%FLYWAY_MAIN_REPO_URL%"=="" (
  set FLYWAY_MAIN_REPO_URL=https://github.com/red-gate/flyway-main.git
)

if "%FLYWAY_OSSIFIER_REPO_URL%"=="" (
  set FLYWAY_OSSIFIER_REPO_URL=https://github.com/red-gate/flyway-ossifier.git
)

setlocal

SET CURRENT_DIR=%cd%

echo ============== CLONE START

echo ============== CLEANING
call clean.cmd || goto :error

echo ============== CLONING MAIN (Git Branch: %FLYWAY_BRANCH%)
git clone -b %FLYWAY_BRANCH% %FLYWAY_MAIN_REPO_URL% || goto :error
echo ============== CLONING OSSIFIER
git clone %FLYWAY_OSSIFIER_REPO_URL% || goto :error

echo ============== CLONE SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== CLONE FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%
