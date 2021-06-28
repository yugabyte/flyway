@echo off

if [%1]==[] goto :noversion
if [%2]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%2
)

if "%FLYWAY_REPO_URL%"=="" (
  set FLYWAY_REPO_URL=https://github.com/flyway/flyway
)

setlocal

SET CURRENT_DIR=%cd%
SET SETTINGS_FILE=%CURRENT_DIR%/settings.xml


echo ============== DEPLOY START
cd flyway
echo ============== DEPLOYING COMMUNITY
call mvn -s "%SETTINGS_FILE%" -Psonatype-release -Pbuild-assemblies deploy scm:tag -DperformRelease=true -DskipTests || goto :error
cd "%CURRENT_DIR%"

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