@echo off

if [%1]==[] goto :noversion
if [%2]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%2
)

setlocal

SET CURRENT_DIR=%cd%

echo ============== RELEASE START (Version: %1, Git Branch: %FLYWAY_BRANCH%)

echo ============== CLONING
call clone.cmd %FLYWAY_BRANCH% || goto :error

echo ============== VERSIONING MASTER
cd flyway-master
call mvn versions:set -DnewVersion=%1 || goto :error
cd ..

echo ============== OSSIFYING
call ossify.cmd || goto :error

echo ============== BUILDING MASTER
cd flyway-master
call mvn -Pbuild-assemblies deploy scm:tag -DperformRelease=true -DskipTests || goto :error
cd ..

echo ============== DEPLOYING
call deploy.cmd %1 %FLYWAY_BRANCH% || goto :error
cd gradle-plugin-publishing
call gradlew clean publishPlugins -Dversion=%1
cd ..

echo ============== RELEASE SUCCESS
cd "%CURRENT_DIR%"
goto :EOF


:error
set ERRORLVL=%errorlevel%
echo ============== RELEASE FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%

:noversion
echo ERROR: Missing version!
echo USAGE: release.cmd 1.2.3
exit /b 1