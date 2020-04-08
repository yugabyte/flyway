@echo off

if [%1]==[] goto :noversion
if [%2]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%2
)

if "%FLYWAY_REPO_URL%"=="" (
  set FLYWAY_REPO_URL=https://github.com/flyway/flyway
)

setlocal

SET CURRENT_DIR=%cd%
SET SETTINGS_FILE=%CURRENT_DIR%/settings.xml


echo ============== DEPLOY START

echo ============== DELETING EXISTING GH REPO
cd ..
if exist flyway (
  rmdir flyway /s /q || goto :error
)

echo ============== CHECKING OUT CURRENT GH REPO (Git Branch: %FLYWAY_BRANCH%)
git clone -b %FLYWAY_BRANCH% %FLYWAY_REPO_URL% || goto :error
cd flyway

echo ============== VERSIONING COMMUNITY
call mvn versions:set -DnewVersion=%1 || goto :error
echo ============== DEPLOYING COMMUNITY
call mvn -s "%SETTINGS_FILE%" -Pbuild-assemblies deploy scm:tag -DperformRelease=true -DskipTests || goto :error
cd "%CURRENT_DIR%"

set SNAPSHOT_REPOSITORY_ID=sonatype-nexus-snapshots
set SNAPSHOT_REPOSITORY_NAME=Sonatype Nexus Snapshots
set SNAPSHOT_REPOSITORY_URL=https://oss.sonatype.org/content/repositories/snapshots

set RELEASE_REPOSITORY_ID=sonatype-nexus-staging
set RELEASE_REPOSITORY_NAME=Nexus Release Repository
set RELEASE_REPOSITORY_URL=https://oss.sonatype.org/service/local/staging/deploy/maven2/

echo ============== DEPLOYING PRO TO %RELEASE_REPOSITORY_URL%
call deployEdition.cmd %1 pro || goto :error

echo ============== DEPLOYING ENTERPRISE TO %RELEASE_REPOSITORY_URL%
call deployEdition.cmd %1 enterprise || goto :error

set SNAPSHOT_REPOSITORY_ID=
set SNAPSHOT_REPOSITORY_NAME=
set SNAPSHOT_REPOSITORY_URL=

set RELEASE_REPOSITORY_ID=flyway-repo-release
set RELEASE_REPOSITORY_NAME=
set RELEASE_REPOSITORY_URL=https://repo.flywaydb.org/repo

echo ============== DEPLOYING PRO TO %RELEASE_REPOSITORY_URL%
call deployEdition.cmd %1 pro || goto :error

echo ============== DEPLOYING ENTERPRISE TO %RELEASE_REPOSITORY_URL%
call deployEdition.cmd %1 enterprise || goto :error

echo ============== DEPLOY SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== DEPLOY FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
exit /b %ERRORLVL%

:noversion
echo ERROR: Missing version!
echo USAGE: deploy.cmd 1.2.3
exit /b 1