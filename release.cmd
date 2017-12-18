@echo off

if [%1]==[] goto :noversion

setlocal

SET CURRENT_DIR=%cd%

echo ============== RELEASE START

echo ============== CLONING
call clone.cmd || goto :error

echo ============== BUILDING MASTER
cd flyway-master
call mvn versions:set -DnewVersion=%1 || goto :error
REM call mvn -PCommandlinePlatformAssemblies deploy scm:tag -DperformRelease=true -DskipTests
cd ..

echo ============== OSSIFYING
call ossify.cmd || goto :error

echo ============== DEPLOYING
call deploy.cmd %1 || goto :error
cd gradle-plugin-publishing
REM call gradlew clean publishPlugins -Dversion=%1
cd ..

echo ============== RELEASE SUCCESS
cd "%CURRENT_DIR%"
goto :EOF


:error
echo ============== RELEASE FAILED WITH ERROR %errorlevel%
cd "%CURRENT_DIR%"
pause
exit /b %errorlevel%

:noversion
echo ERROR: Missing version!
echo USAGE: release.cmd 1.2.3
exit /b 1