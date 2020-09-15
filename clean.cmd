@echo off

echo ============== CLEANING MAIN
if exist flyway-main (
  rmdir /s/q flyway-main || goto :error
)
echo ============== CLEANING OSSIFIER
if exist flyway-ossifier (
  rmdir /s/q flyway-ossifier || goto :error
)
echo ============== CLEANING COMMUNITY
if exist flyway (
  rmdir /s/q flyway || goto :error
)
echo ============== CLEANING ENTERPRISE
if exist flyway-enterprise (
  rmdir /s/q flyway-enterprise || goto :error
)

echo ============== CLEANING SUCCESS
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== CLEANING FAILED WITH ERROR %ERRORLVL%
exit /b %ERRORLVL%