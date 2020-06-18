@echo off

if [%1]==[] goto :noversion
if [%2]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%2
)

setlocal

SET CURRENT_DIR=%cd%
SET SETTINGS_FILE=%CURRENT_DIR%/settings.xml

echo ============== RELEASE START (Version: %1, Git Branch: %FLYWAY_BRANCH%)

echo ============== CLONING
call clone.cmd %FLYWAY_BRANCH% || goto :error

echo ============== VERSIONING MAIN
cd flyway-main
call mvn versions:set -DnewVersion=%1 || goto :error
cd ..

echo ============== OSSIFYING
call ossify.cmd %SETTINGS_FILE% || goto :error

echo ============== BUILDING MAIN
cd flyway-main
call mvn -s "%SETTINGS_FILE%" -Pbuild-assemblies -Prepo-proxy-release deploy scm:tag -DperformRelease=true -DskipTests || goto :error
cd ..

echo ============== DEPLOYING
call deploy.cmd %1 %FLYWAY_BRANCH% || goto :error
cd gradle-plugin-publishing
call gradlew -b release-community.gradle clean publishPlugins -Dversion=%1 -Dgradle.publish.key=%FLYWAY_GRADLE_KEY% -Dgradle.publish.secret=%FLYWAY_GRADLE_SECRET% || goto :error
call gradlew -b release-pro.gradle clean publishPlugins -Dversion=%1 -Dgradle.publish.key=%FLYWAY_GRADLE_KEY% -Dgradle.publish.secret=%FLYWAY_GRADLE_SECRET% || goto :error
call gradlew -b release-enterprise.gradle clean publishPlugins -Dversion=%1 -Dgradle.publish.key=%FLYWAY_GRADLE_KEY% -Dgradle.publish.secret=%FLYWAY_GRADLE_SECRET% || goto :error
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
