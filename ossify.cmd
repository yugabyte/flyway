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

SET CURRENT_DIR=%cd%

echo ============== OSSIFY START

echo ============== BUILDING OSSIFIER
cd flyway-ossifier
call mvn clean package || goto :error
echo ============== RUNNING OSSIFIER
"%JAVA_HOME%\bin\java.exe" -jar target\flyway-ossifier-1.0-SNAPSHOT.jar "%CURRENT_DIR%" || goto :error

echo ============== BUILDING ENTERPRISE
cd "%CURRENT_DIR%\flyway-enterprise"
call mvn -s %1 -U dependency:purge-local-repository clean install || goto :error
call mvn -s %1 -Pbuild-assemblies clean install javadoc:jar -T3 || goto :error

echo ============== BUILDING COMMUNITY
cd "%CURRENT_DIR%\flyway"
call mvn -s %1 -U dependency:purge-local-repository clean install || goto :error
call mvn -s %1 -Pbuild-assemblies clean install javadoc:jar -T3 || goto :error

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