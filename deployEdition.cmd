@echo off

if [%1]==[] goto :usage
if [%2]==[] goto :usage

setlocal

SET QUALIFIER=""

SET CURRENT_DIR=%cd%
SET SETTINGS_FILE=%CURRENT_DIR%/settings.xml

echo ============== DEPLOY %2 START
cd flyway-%2

set VERSION=%1
set GROUP_ID=org.flywaydb.%2

SET RELEASE_REPOSITORY_URL=https://oss.sonatype.org/service/local/staging/deploy/maven2/
SET RELEASE_REPOSITORY_ID=sonatype-nexus-staging
SET PROFILE=sonatype-release
SET FAKE_SOURCES=%CURRENT_DIR%/fake-sources/flyway-sources.jar

echo ============== DEPLOYING %2 TO %RELEASE_REPOSITORY_URL%

echo ============== DEPLOYING %2 PARENT TO %RELEASE_REPOSITORY_URL%
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=pom.xml -DgroupId=%GROUP_ID% -DartifactId=flyway-parent -Dversion=%VERSION% -Dpackaging=pom -DupdateReleaseInfo=true -Dsources=%FAKE_SOURCES% || goto :error
echo ============== DEPLOYING %2 CORE TO %RELEASE_REPOSITORY_URL%
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-core/target/flyway-core-%VERSION%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-core -Dversion=%VERSION% -Dpackaging=jar -Djavadoc=flyway-core/target/flyway-core-%VERSION%-javadoc.jar -Dsources=%FAKE_SOURCES% -DpomFile=flyway-core/pom.xml -DupdateReleaseInfo=true -DperformRelease=true || goto :error
echo ============== DEPLOYING %2 GRADLE PLUGIN TO %RELEASE_REPOSITORY_URL%
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-gradle-plugin/target/flyway-gradle-plugin-%VERSION%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-gradle-plugin -Dversion=%VERSION% -Dpackaging=jar -Djavadoc=flyway-gradle-plugin/target/flyway-gradle-plugin-%VERSION%-javadoc.jar -Dsources=%FAKE_SOURCES% -DpomFile=flyway-gradle-plugin/pom.xml -DupdateReleaseInfo=true -DperformRelease=true || goto :error
echo ============== DEPLOYING %2 MAVEN PLUGIN TO %RELEASE_REPOSITORY_URL%
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-maven-plugin/target/flyway-maven-plugin-%VERSION%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-maven-plugin -Dversion=%VERSION% -Dpackaging=jar -Djavadoc=flyway-maven-plugin/target/flyway-maven-plugin-%VERSION%-javadoc.jar -Dsources=%FAKE_SOURCES% -DpomFile=flyway-maven-plugin/pom.xml -DupdateReleaseInfo=true -DperformRelease=true || goto :error
echo ============== DEPLOYING %2 COMMANDLINE TO %RELEASE_REPOSITORY_URL%
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=jar -Djavadoc=flyway-commandline/target/flyway-commandline-%VERSION%-javadoc.jar -Dsources=%FAKE_SOURCES% -DpomFile=flyway-commandline/pom.xml -DupdateReleaseInfo=true -DperformRelease=true || goto :error
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-windows-x64.zip -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=zip -DgeneratePom=false -Dclassifier=windows-x64 -DperformRelease=true -Dsources=%FAKE_SOURCES% || goto :error
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-linux-x64.tar.gz -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=tar.gz -DgeneratePom=false -Dclassifier=linux-x64 -DperformRelease=true -Dsources=%FAKE_SOURCES% || goto :error
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-macosx-x64.tar.gz -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=tar.gz -DgeneratePom=false -Dclassifier=macosx-x64 -DperformRelease=true -Dsources=%FAKE_SOURCES% || goto :error

echo ============== DEPLOYING %2 GCP BigQuery SUPPORT TO %RELEASE_REPOSITORY_URL%
if exists flyway-gcp-bigquery/target/flyway-gcp-bigquery-%VERSION%-BETA.jar (
%QUALIFIER%=-BETA
)
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-gcp-bigquery/target/flyway-gcp-bigquery-%VERSION%%QUALIFIER%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-gcp-bigquery -Dversion=%VERSION%%QUALIFIER% -Dpackaging=jar -Djavadoc=flyway-gcp-bigquery/target/flyway-gcp-bigquery-%VERSION%%QUALIFIER%-javadoc.jar -Dsources=%FAKE_SOURCES% -DpomFile=flyway-gcp-bigquery/pom.xml -DupdateReleaseInfo=true -DperformRelease=true || goto :error
echo ============== DEPLOYING %2 GCP Spanner SUPPORT TO %RELEASE_REPOSITORY_URL%
if exists flyway-gcp-spanner/target/flyway-gcp-spanner-%VERSION%-BETA.jar (
%QUALIFIER%=-BETA
)
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-gcp-spanner/target/flyway-gcp-spanner-%VERSION%%QUALIFIER%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-gcp-spanner -Dversion=%VERSION%%QUALIFIER% -Dpackaging=jar -Djavadoc=flyway-gcp-spanner/target/flyway-gcp-spanner-%VERSION%%QUALIFIER%-javadoc.jar -Dsources=%FAKE_SOURCES% -DpomFile=flyway-gcp-spanner/pom.xml -DupdateReleaseInfo=true -DperformRelease=true || goto :error


echo ============== DEPLOY %2 SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== DEPLOY %2 FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
exit /b %ERRORLVL%

:usage
echo ERROR: Missing version or edition!
echo USAGE: deployEdition.cmd 1.2.3 enterprise
exit /b 1