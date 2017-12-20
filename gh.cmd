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

SET CURRENT_DIR=%cd%

echo ============== GH START

echo ============== CLONING
call clone.cmd || goto :error

echo ============== BUILDING MASTER
cd flyway-master
call mvn -PCommandlinePlatformAssemblies install -DskipTests || goto :error
cd ..

echo ============== OSSIFYING
call ossify.cmd || goto :error

echo ============== DELETING EXISTING GH REPO
cd ..
if exist flyway (
  rmdir flyway /s /q || goto :error
)

echo ============== CHECKING OUT CURRENT GH REPO
git clone https://github.com/flyway/flyway --depth=1 || goto :error

echo ============== DELETING EXISTING GH SOURCES
DEL /Q flyway\*.* || goto :error
DEL /S /Q flyway\.mvn || goto :error
DEL /S /Q flyway\flyway-core || goto :error
DEL /S /Q flyway\flyway-commandline || goto :error
DEL /S /Q flyway\flyway-maven-plugin || goto :error
DEL /S /Q flyway\flyway-gradle-plugin || goto :error

echo ============== COPYING OSSIFIED SOURCES
robocopy flyway-release\flyway flyway /s /e
IF %ERRORLEVEL% NEQ 3 goto :error

echo ============== SHOW STATUS
cd flyway
git status || goto :error
git --no-pager diff || goto :error

echo ============== GH SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== GH FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%