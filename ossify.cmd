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

echo ============== OSSIFY START

echo ============== BUILDING OSSIFIER
cd flyway-ossifier
call mvn clean package || goto :error
echo ============== RUNNING OSSIFIER
java -jar target\flyway-ossifier-1.0-SNAPSHOT.jar "%CURRENT_DIR%" || goto :error

echo ============== BUILDING PRO
cd "%CURRENT_DIR%\flyway-pro"
call mvn -Pbuild-assemblies clean install javadoc:jar -T3 || goto :error
cd flyway-distribution
call mvn clean package || goto :error

echo ============== BUILDING ENTERPRISE
cd "%CURRENT_DIR%\flyway-enterprise"
call mvn -Pbuild-assemblies clean install javadoc:jar -T3 || goto :error
cd flyway-distribution
call mvn clean package || goto :error

echo ============== BUILDING TRIAL
cd "%CURRENT_DIR%\flyway-trial"
call mvn -Pbuild-assemblies clean install javadoc:jar -T3 || goto :error
cd flyway-distribution
call mvn clean package || goto :error

echo ============== BUILDING COMMUNITY
cd "%CURRENT_DIR%\flyway"
call mvn clean install javadoc:jar -T3 || goto :error

echo ============== OSSIFY SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== OSSIFY FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
pause
exit /b %ERRORLVL%