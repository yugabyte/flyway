@echo off

if [%1]==[] goto :noversion

setlocal

SET CURRENT_DIR=%cd%

echo ============== DEPLOY START

echo ============== DEPLOYING PRO
call deployEdition.cmd %1 pro || goto :error

echo ============== DEPLOYING ENTERPRISE
call deployEdition.cmd %1 enterprise || goto :error

echo ============== DEPLOY SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
echo ============== DEPLOY FAILED WITH ERROR %errorlevel%
cd "%CURRENT_DIR%"
exit /b %errorlevel%

:noversion
echo ERROR: Missing version!
echo USAGE: deploy.cmd 1.2.3
exit /b 1