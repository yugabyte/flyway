call clean.cmd

git clone https://github.com/flyway/flyway.git --depth=1

cd flyway
call mvn versions:set -DnewVersion=%1
call mvn -PCommandlinePlatformAssemblies deploy scm:tag -DperformRelease=true -DskipTests
cd ..
call gradlew clean publishPlugins -Dversion=%1