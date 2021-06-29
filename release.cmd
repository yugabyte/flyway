@echo off

if [%1]==[] goto :noversion
set VERSION=%1

if [%2]==[] (
  set FLYWAY_BRANCH=master
) else (
  set FLYWAY_BRANCH=%2
)

if [%3]==[] (
  set FLYWAY_BETA=""
) else (
  set FLYWAY_BETA=%3
)

setlocal

SET FLYWAY_RELEASE_DIR=%cd%
SET SETTINGS_FILE=%FLYWAY_RELEASE_DIR%/settings.xml
set OSSIFY_TEST_MODE=false
set GROUP_ID=org.flywaydb.enterprise
SET RELEASE_REPOSITORY_URL=https://oss.sonatype.org/service/local/staging/deploy/maven2/
SET RELEASE_REPOSITORY_ID=sonatype-nexus-staging
SET PROFILE=sonatype-release
SET FAKE_SOURCES=%FLYWAY_RELEASE_DIR%/fake-sources/flyway-sources.jar
SET QUALIFIER=""

echo ============== RELEASE START (Version: %VERSION%, Git Branch: %FLYWAY_BRANCH%)

echo ============== CLONING
git clone -b %FLYWAY_BRANCH% https://github.com/red-gate/flyway-main.git || goto :error

echo ============== VERSIONING MAIN
cd "%FLYWAY_RELEASE_DIR%\flyway-main"
call mvn versions:set -DnewVersion=%VERSION% || goto :error
if NOT [%FLYWAY_BETA%]==[] (
  call mvn versions:set -DnewVersion=%VERSION%-BETA -pl %FLYWAY_BETA% || goto :error
)

echo ============== RUNNING OSSIFIER
cd "%FLYWAY_RELEASE_DIR%\flyway-main\master-only\flyway-ossifier"
@REM OSSifier reads the OSSIFY_TEST_MODE environment variable
call mvn clean compile exec:java -Dexec.mainClass="com.boxfuse.flyway.ossifier.OSSifier" -Dexec.args="%FLYWAY_RELEASE_DIR% %FLYWAY_RELEASE_DIR%/flyway-main" -DskipTests -DskipITs || goto :error

echo ============== BUILDING ENTERPRISE
cd "%FLYWAY_RELEASE_DIR%\flyway-enterprise"
call mvn -s %SETTINGS_FILE% -U dependency:purge-local-repository clean install -DskipTests -DskipITs || goto :error
call mvn -s %SETTINGS_FILE% -Pbuild-assemblies clean install javadoc:jar -T3 -DskipTests -DskipITs || goto :error

echo ============== BUILDING COMMUNITY
cd "%FLYWAY_RELEASE_DIR%\flyway"
call mvn -s %SETTINGS_FILE% -U dependency:purge-local-repository clean install -DskipTests -DskipITs || goto :error
call mvn -s %SETTINGS_FILE% -Pbuild-assemblies clean install javadoc:jar -T3 -DskipTests -DskipITs || goto :error

echo ============== BUILDING MAIN
cd "%FLYWAY_RELEASE_DIR%\flyway-main"
call mvn -s "%SETTINGS_FILE%" -Pbuild-assemblies -Prepo-proxy-release deploy scm:tag -DperformRelease=true -DskipTests -DskipITs || goto :error

echo ============== DEPLOYING
SET PACKAGES="flyway-core,flyway-gradle-plugin,flyway-maven-plugin,flyway-commandline,flyway-community-db-support,flyway-gcp-bigquery,flyway-gcp-spanner"

echo ============== DEPLOYING COMMUNITY
cd "%FLYWAY_RELEASE_DIR%\flyway"
call mvn -s "%SETTINGS_FILE%" -Psonatype-release -Pbuild-assemblies deploy scm:tag -DperformRelease=true -DskipTests -DskipITs -pl %PACKAGES% -am || goto :error

echo ============== DEPLOYING ENTERPRISE TO %RELEASE_REPOSITORY_URL%
cd "%FLYWAY_RELEASE_DIR%\flyway-enterprise"
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=pom.xml -DgroupId=%GROUP_ID% -DartifactId=flyway-parent -Dversion=%VERSION% -Dpackaging=pom -DupdateReleaseInfo=true -Dsources=%FAKE_SOURCES% || goto :error
for /F "tokens=1* delims=," %%f in ("%PACKAGES%") do (
  if exists %%f/target/%%f-%VERSION%-BETA.jar (
    %QUALIFIER%=-BETA
  )
  call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=%%f/target/%%f-%VERSION%%QUALIFIER%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-core -Dversion=%VERSION%%QUALIFIER% -Dpackaging=jar -Djavadoc=%%f/target/%%f-%VERSION%%QUALIFIER%-javadoc.jar -Dsources=%FAKE_SOURCES% -DpomFile=%%f/pom.xml -DupdateReleaseInfo=true -DperformRelease=true || goto :error
  %QUALIFIER%=""
)
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-windows-x64.zip -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=zip -DgeneratePom=false -Dclassifier=windows-x64 -DperformRelease=true -Dsources=%FAKE_SOURCES% || goto :error
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-linux-x64.tar.gz -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=tar.gz -DgeneratePom=false -Dclassifier=linux-x64 -DperformRelease=true -Dsources=%FAKE_SOURCES% || goto :error
call mvn -s "%SETTINGS_FILE%" -f pom.xml gpg:sign-and-deploy-file -P%PROFILE% -DrepositoryId=%RELEASE_REPOSITORY_ID% -Durl=%RELEASE_REPOSITORY_URL% -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-macosx-x64.tar.gz -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=tar.gz -DgeneratePom=false -Dclassifier=macosx-x64 -DperformRelease=true -Dsources=%FAKE_SOURCES% || goto :error

echo ============== PUBLISHING GRADLE
cd "%FLYWAY_RELEASE_DIR%\gradle-plugin-publishing"
call gradlew -b release-community.gradle clean publishPlugins -Dversion=%VERSION% -Dgradle.publish.key=%FLYWAY_GRADLE_KEY% -Dgradle.publish.secret=%FLYWAY_GRADLE_SECRET% || goto :error
call gradlew -b release-enterprise.gradle clean publishPlugins -Dversion=%VERSION% -Dgradle.publish.key=%FLYWAY_GRADLE_KEY% -Dgradle.publish.secret=%FLYWAY_GRADLE_SECRET% || goto :error

echo ============== RELEASE SUCCESS
cd "%FLYWAY_RELEASE_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== RELEASE FAILED WITH ERROR %ERRORLVL%
cd "%FLYWAY_RELEASE_DIR%"
pause
exit /b %ERRORLVL%

:noversion
echo ERROR: Missing version!
echo USAGE: release.cmd 1.2.3
exit /b 1
