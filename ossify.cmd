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

if [%1]==[] goto :nosettings

if [%2]==[] (
  set OSSIFY_TEST_MODE=false
) else (
  set OSSIFY_TEST_MODE=%2
)

SET CURRENT_DIR=%cd%

echo ============== OSSIFY START

cd flyway-main/master-only/flyway-ossifier

echo ============== RUNNING OSSIFIER
@REM Ossifier reads the OSSIFY_TEST_MODE environment variable
call mvn clean compile exec:java -Dexec.mainClass="com.boxfuse.flyway.ossifier.OSSifier" -Dexec.args="%CURRENT_DIR% %CURRENT_DIR%/flyway-main" -DskipTests -DskipITs || goto :error

cd ../../

echo ============== BUILDING ENTERPRISE
cd "%CURRENT_DIR%\flyway-enterprise"
call mvn -s %1 -U dependency:purge-local-repository clean install -DskipTests -DskipITs || goto :error
call mvn -s %1 -Pbuild-assemblies clean install javadoc:jar -T3 -DskipTests -DskipITs || goto :error

echo ============== BUILDING COMMUNITY
cd "%CURRENT_DIR%\flyway"
call mvn -s %1 -U dependency:purge-local-repository clean install -DskipTests -DskipITs || goto :error
call mvn -s %1 -Pbuild-assemblies clean install javadoc:jar -T3 -DskipTests -DskipITs || goto :error

echo ============== OSSIFY SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== OSSIFY FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%

:nosettings
echo ERROR: Missing settings file!
echo USAGE: ossify.cmd path/to/settings.xml
exit /b 1
