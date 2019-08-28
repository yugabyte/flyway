@REM
@REM Copyright 2010-2017 Boxfuse GmbH
@REM
@REM INTERNAL RELEASE. ALL RIGHTS RESERVED.
@REM
@REM Must
@REM be
@REM exactly
@REM 13 lines
@REM to match
@REM community
@REM edition
@REM license
@REM length.
@REM

@echo off

setlocal

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

SET CURRENT_DIR=%cd%

echo ============== GH START (Git Branch: %FLYWAY_BRANCH%)

echo ============== DELETING EXISTING GH REPO
cd ..
if exist flyway (
  rmdir flyway /s /q || goto :error
)
cd "%CURRENT_DIR%"

echo ============== CLONING
call clone.cmd %FLYWAY_BRANCH% %FLYWAY_MASTER_REPO_URL% %FLYWAY_OSSIFIER_REPO_URL% || goto :error

echo ============== BUILDING MASTER
SET SETTINGS_FILE_PATH=%cd%/maven-repo-settings.xml

cd flyway-master
call mvn -s %SETTINGS_FILE_PATH% -Pbuild-assemblies install -DskipTests || goto :error
cd ..

echo ============== OSSIFYING
call ossify.cmd || goto :error

echo ============== CHECKING OUT CURRENT GH REPO (Git Branch: %FLYWAY_BRANCH%)
SET FLYWAY_RELEASE_DIR=%cd%
cd ..
git clone -b %FLYWAY_BRANCH% https://github.com/flyway/flyway --depth=1 || goto :error

echo ============== DELETING EXISTING GH SOURCES
DEL /Q flyway\*.* || goto :error
DEL /S /Q flyway\.mvn || goto :error
DEL /S /Q flyway\flyway-core || goto :error
DEL /S /Q flyway\flyway-commandline || goto :error
DEL /S /Q flyway\flyway-maven-plugin || goto :error
DEL /S /Q flyway\flyway-gradle-plugin || goto :error

echo ============== COPYING OSSIFIED SOURCES
robocopy %FLYWAY_RELEASE_DIR%\flyway flyway /s /e /XD target
IF %ERRORLEVEL% NEQ 3 goto :error

echo ============== SHOW STATUS
cd flyway
git status || goto :error
git --no-pager diff || goto :error
git --output=changes.patch diff || goto :error

echo ============== GH SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== GH FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%