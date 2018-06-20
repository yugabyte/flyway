@echo off

if [%1]==[] goto :noversion
if [%2]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%2
)

setlocal

SET CURRENT_DIR=%cd%

echo ============== DEPLOY START

echo ============== DELETING EXISTING GH REPO
cd ..
if exist flyway (
  rmdir flyway /s /q || goto :error
)

echo ============== CHECKING OUT CURRENT GH REPO (Git Branch: %FLYWAY_BRANCH%)
git clone -b %FLYWAY_BRANCH% https://github.com/flyway/flyway || goto :error
cd flyway

echo ============== VERSIONING COMMUNITY
call mvn versions:set -DnewVersion=%1 || goto :error
echo ============== DEPLOYING COMMUNITY
call mvn -PCommandlinePlatformAssemblies deploy scm:tag -DperformRelease=true -DskipTests || goto :error
cd "%CURRENT_DIR%"

echo ============== DEPLOYING PRO
call deployEdition.cmd %1 pro || goto :error

echo ============== DEPLOYING ENTERPRISE
call deployEdition.cmd %1 enterprise || goto :error

echo ============== DEPLOY SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== DEPLOY FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
exit /b %ERRORLVL%

:noversion
echo ERROR: Missing version!
echo USAGE: deploy.cmd 1.2.3
exit /b 1