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

@REM Either both or neither of these arguments must be suppplied.
if [%1]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%1
)
if [%2]==[] (
  set OSSIFY_TEST_MODE=false
) else (
  set OSSIFY_TEST_MODE=%2
)

SET FLYWAY_RELEASE_DIR=%cd%
SET SETTINGS_FILE=%FLYWAY_RELEASE_DIR%/settings.xml

echo ============== GH START (Git Branch: %FLYWAY_BRANCH%)

echo ============== CLONING
git clone -b %FLYWAY_BRANCH% %FLYWAY_MAIN_REPO_URL% || goto :error

echo ============== BUILDING MAIN
cd %FLYWAY_RELEASE_DIR%\flyway-main
call mvn -s "%SETTINGS_FILE%" -Pbuild-assemblies install -DskipTests -DskipITs || goto :error

echo ============== RUNNING OSSIFIER
cd %FLYWAY_RELEASE_DIR%\flyway-main\master-only\flyway-ossifier
@REM OSSifier reads the OSSIFY_TEST_MODE environment variable
call mvn clean compile exec:java -Dexec.mainClass="com.boxfuse.flyway.ossifier.OSSifier" -Dexec.args="%FLYWAY_RELEASE_DIR% %FLYWAY_RELEASE_DIR%/flyway-main" -DskipTests -DskipITs || goto :error

echo ============== BUILDING ENTERPRISE
cd %FLYWAY_RELEASE_DIR%\flyway-enterprise
call mvn -s %SETTINGS_FILE% -U dependency:purge-local-repository clean install -DskipTests -DskipITs || goto :error
call mvn -s %SETTINGS_FILE% -Pbuild-assemblies clean install javadoc:jar -T3 -DskipTests -DskipITs || goto :error

echo ============== BUILDING COMMUNITY
cd %FLYWAY_RELEASE_DIR%\flyway
call mvn -s %SETTINGS_FILE% -U dependency:purge-local-repository clean install -DskipTests -DskipITs || goto :error
call mvn -s %SETTINGS_FILE% -Pbuild-assemblies clean install javadoc:jar -T3 -DskipTests -DskipITs || goto :error

echo ============== CHECKING OUT CURRENT FLYWAY PUBLIC (Git Branch: %FLYWAY_BRANCH%)
git clone -b %FLYWAY_BRANCH% https://github.com/flyway/flyway --depth=1 flyway-public || goto :error

echo ============== DELETING EXISTING FLYWAY PUBLIC SOURCES
DEL /Q flyway-public\*.* || goto :error
DEL /S /Q flyway-public\.mvn || goto :error
DEL /S /Q flyway-public\flyway-core || goto :error
DEL /S /Q flyway-public\flyway-commandline || goto :error
DEL /S /Q flyway-public\flyway-maven-plugin || goto :error
DEL /S /Q flyway-public\flyway-gradle-plugin || goto :error

echo ============== COPYING OSSIFIED SOURCES
robocopy %FLYWAY_RELEASE_DIR%\flyway flyway-public /s /e /XD target
IF %ERRORLEVEL% NEQ 3 goto :error

echo ============== SHOW STATUS
cd %FLYWAY_RELEASE_DIR%\flyway-public
git status || goto :error
git --no-pager diff || goto :error

echo =============== PRODUCE PATCH FILE
git add .
git diff --cached --output=%FLYWAY_RELEASE_DIR%\changes.patch || goto :error

echo ============== GH SUCCESS
cd %FLYWAY_RELEASE_DIR%
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== GH FAILED WITH ERROR %ERRORLVL%
cd %FLYWAY_RELEASE_DIR%
pause
exit /b %ERRORLVL%