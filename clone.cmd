@echo off

if [%1]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%1
)

if [%2]==[] (
  set FLYWAY_MASTER_REPO_URL=https://github.com/flyway/flyway-master.git
) else (
  set FLYWAY_MASTER_REPO_URL=%2
)

if [%3]==[] (
  set FLYWAY_OSSIFIER_REPO_URL=https://github.com/flyway/flyway-ossifier.git
) else (
  set FLYWAY_OSSIFIER_REPO_URL=%3
)

setlocal

SET CURRENT_DIR=%cd%

echo ============== CLONE START

echo ============== CLEANING
call clean.cmd || goto :error

echo ============== CLONING MASTER (Git Branch: %FLYWAY_BRANCH%)
git clone -b %FLYWAY_BRANCH% %FLYWAY_MASTER_REPO_URL% || goto :error
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
