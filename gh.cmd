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

SET CURRENT_DIR=%cd%
SET SETTINGS_FILE=%CURRENT_DIR%/settings.xml

echo ============== GH START (Git Branch: %FLYWAY_BRANCH%)

echo ============== DELETING EXISTING GH REPO
cd ..
if exist flyway (
  rmdir flyway /s /q || goto :error
)
cd "%CURRENT_DIR%"

echo ============== CLONING
call clone.cmd %FLYWAY_BRANCH% || goto :error

echo ============== BUILDING MASTER

cd flyway-master
call mvn -s "%SETTINGS_FILE%" -Pbuild-assemblies install -DskipTests || goto :error
cd ..

echo ============== BUILDING EDITIONS
call buildEdition.cmd || goto :error

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

echo =============== PRODUCE PATCH FILE
git add .
git diff --cached --output=%FLYWAY_RELEASE_DIR%\changes.patch || goto :error

echo ============== GH SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== GH FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%