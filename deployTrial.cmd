@echo off

if [%1]==[] goto :usage

setlocal

SET CURRENT_DIR=%cd%

echo ============== DEPLOY trial START
cd flyway-trial

set VERSION=%1
set GROUP_ID=org.flywaydb.trial

echo ============== DEPLOYING trial PARENT
call mvn -f pom.xml deploy:deploy-file -DrepositoryId=flyway-repo -Durl=s3://flyway-repo/release -Dfile=pom.xml -DgroupId=%GROUP_ID% -DartifactId=flyway-parent -Dversion=%VERSION% -Dpackaging=pom -DupdateReleaseInfo=true || goto :error
echo ============== DEPLOYING trial CORE
call mvn -f pom.xml deploy:deploy-file -DrepositoryId=flyway-repo -Durl=s3://flyway-repo/release -Dfile=flyway-core/target/flyway-core-%VERSION%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-core -Dversion=%VERSION% -Dpackaging=jar -Djavadoc=flyway-core/target/flyway-core-%VERSION%-javadoc.jar -DpomFile=flyway-core/pom.xml -DupdateReleaseInfo=true || goto :error
echo ============== DEPLOYING trial GRADLE PLUGIN
call mvn -f pom.xml deploy:deploy-file -DrepositoryId=flyway-repo -Durl=s3://flyway-repo/release -Dfile=flyway-gradle-plugin/target/flyway-gradle-plugin-%VERSION%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-gradle-plugin -Dversion=%VERSION% -Dpackaging=jar -Djavadoc=flyway-gradle-plugin/target/flyway-gradle-plugin-%VERSION%-javadoc.jar -DpomFile=flyway-gradle-plugin/pom.xml -DupdateReleaseInfo=true || goto :error
echo ============== DEPLOYING trial MAVEN PLUGIN
call mvn -f pom.xml deploy:deploy-file -DrepositoryId=flyway-repo -Durl=s3://flyway-repo/release -Dfile=flyway-maven-plugin/target/flyway-maven-plugin-%VERSION%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-maven-plugin -Dversion=%VERSION% -Dpackaging=jar -Djavadoc=flyway-maven-plugin/target/flyway-maven-plugin-%VERSION%-javadoc.jar -DpomFile=flyway-maven-plugin/pom.xml -DupdateReleaseInfo=true || goto :error
echo ============== DEPLOYING trial COMMANDLINE
call mvn -f pom.xml deploy:deploy-file -DrepositoryId=flyway-repo -Durl=s3://flyway-repo/release -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%.jar -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=jar -Djavadoc=flyway-commandline/target/flyway-commandline-%VERSION%-javadoc.jar -DpomFile=flyway-commandline/pom.xml -DupdateReleaseInfo=true || goto :error
call mvn -f pom.xml deploy:deploy-file -DrepositoryId=flyway-repo -Durl=s3://flyway-repo/release -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-windows-x64.zip -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=zip -DgeneratePom=false -Dclassifier=windows-x64 || goto :error
call mvn -f pom.xml deploy:deploy-file -DrepositoryId=flyway-repo -Durl=s3://flyway-repo/release -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-linux-x64.tar.gz -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=tar.gz -DgeneratePom=false -Dclassifier=linux-x64 || goto :error
call mvn -f pom.xml deploy:deploy-file -DrepositoryId=flyway-repo -Durl=s3://flyway-repo/release -Dfile=flyway-commandline/target/flyway-commandline-%VERSION%-macosx-x64.tar.gz -DgroupId=%GROUP_ID% -DartifactId=flyway-commandline -Dversion=%VERSION% -Dpackaging=tar.gz -DgeneratePom=false -Dclassifier=macosx-x64 || goto :error


echo ============== DEPLOY trial SUCCESS
cd "%CURRENT_DIR%"
goto :EOF

:error
set ERRORLVL=%errorlevel%
echo ============== DEPLOY trial FAILED WITH ERROR %ERRORLVL%
cd "%CURRENT_DIR%"
exit /b %ERRORLVL%

:usage
echo ERROR: Missing version!
echo USAGE: deployEdition.cmd 1.2.3
exit /b 1