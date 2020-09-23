@echo off

setlocal

SET CURRENT_DIR=%cd%
SET SETTINGS_FILE=%CURRENT_DIR%/settings.xml

if "%FLYWAY_REPO_URL%"=="" (
  set FLYWAY_REPO_URL=https://github.com/flyway/flyway
)

echo ============= BUILDING EDITIONS

call ossify.cmd %SETTINGS_FILE% || goto :error

echo ============== CREATING OUTPUT DIRECTORY STRUCTURE

SET VERSION=0-SNAPSHOT

if exist artifacts (
  rmdir artifacts /s /q || goto :error
)

mkdir artifacts
mkdir artifacts\community
mkdir artifacts\enterprise

echo ============== COPYING ARTIFACTS TO OUTPUT DIRECTORY

robocopy flyway\flyway-core\target artifacts\community flyway-core-%VERSION%.jar
robocopy flyway\flyway-gradle-plugin\target artifacts\community flyway-gradle-plugin-%VERSION%.jar
robocopy flyway\flyway-maven-plugin\target artifacts\community flyway-maven-plugin-%VERSION%.jar-%VERSION%.jar
robocopy flyway\flyway-commandline\target artifacts\community flyway-commandline-%VERSION%.jar
robocopy flyway\flyway-commandline\target artifacts\community flyway-commandline-%VERSION%-windows-x64.zip 
robocopy flyway\flyway-commandline\target artifacts\community flyway-commandline-%VERSION%-linux-x64.tar.gz
robocopy flyway\flyway-commandline\target artifacts\community flyway-commandline-%VERSION%-macosx-x64.tar.gz

robocopy flyway-enterprise\flyway-core\target artifacts\enterprise flyway-core-%VERSION%.jar
robocopy flyway-enterprise\flyway-gradle-plugin\target artifacts\enterprise flyway-gradle-plugin-%VERSION%.jar
robocopy flyway-enterprise\flyway-maven-plugin\target artifacts\enterprise flyway-maven-plugin-%VERSION%.jar-%VERSION%.jar
robocopy flyway-enterprise\flyway-commandline\target artifacts\enterprise flyway-commandline-%VERSION%.jar
robocopy flyway-enterprise\flyway-commandline\target artifacts\enterprise flyway-commandline-%VERSION%-windows-x64.zip
robocopy flyway-enterprise\flyway-commandline\target artifacts\enterprise flyway-commandline-%VERSION%-linux-x64.tar.gz
robocopy flyway-enterprise\flyway-commandline\target artifacts\enterprise flyway-commandline-%VERSION%-macosx-x64.tar.gz

echo ============== BUILD EDITION SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== BUILD EDITION FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%