@echo off

echo ============== CLEANING MASTER
if exist flyway-master (
  rmdir /s/q flyway-master || goto :error
)
echo ============== CLEANING OSSIFIER
if exist flyway-ossifier (
  rmdir /s/q flyway-ossifier || goto :error
)
echo ============== CLEANING COMMUNITY
if exist flyway (
  rmdir /s/q flyway || goto :error
)
echo ============== CLEANING PRO
if exist flyway-pro (
  rmdir /s/q flyway-pro || goto :error
)
echo ============== CLEANING ENTERPRISE
if exist flyway-enterprise (
  rmdir /s/q flyway-enterprise || goto :error
)
echo ============== CLEANING TRIAL
if exist flyway-trial (
  rmdir /s/q flyway-trial || goto :error
)

echo ============== CLEANING SUCCESS
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== CLEANING FAILED WITH ERROR %ERRORLVL%
exit /b %ERRORLVL%