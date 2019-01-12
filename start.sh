#!/bin/bash

# Cache sudo credentials
sudo echo

# WSL screen hotfix
if grep -q Microsoft /proc/version; then
    sudo service screen-cleanup start
fi

# Prepare workdir
rm -rf workdir
mkdir workdir
cd workdir

# Prepare DB
if grep -q Microsoft /proc/version; then
    echo Assuming mysql server is running on windows side
    mysql -h 127.0.0.1 -u root -e "DROP DATABASE authmetest;"
    mysql -h 127.0.0.1 -u root -e "CREATE DATABASE authmetest;"
else
    sudo service mysql start
    mysql -u root -e "DROP DATABASE authmetest;"
    mysql -u root -e "CREATE DATABASE authmetest;"
fi

# Download stuff
mkdir tmp
cd tmp
#wget --no-verbose --no-hsts --show-progress --trust-server-names https://ci.codemc.org/job/sgdc3/job/DownloadScraper/lastSuccessfulBuild/artifact/target/downloadscraper-1.0-SNAPSHOT.jar
wget --no-verbose --no-hsts --show-progress --trust-server-names https://papermc.io/ci/job/Paper-1.13/lastSuccessfulBuild/artifact/paperclip.jar
wget --no-verbose --no-hsts --show-progress --trust-server-names https://papermc.io/ci/view/WaterfallMC/job/Waterfall/lastSuccessfulBuild/artifact/Waterfall-Proxy/bootstrap/target/Waterfall.jar
#java -jar downloadscraper-1.0-SNAPSHOT.jar ./ "https://ci.codemc.org/job/AuthMe/job/AuthMeReloaded/" firstMatch "AuthMe-.*\SNAPSHOT.jar"
#java -jar downloadscraper-1.0-SNAPSHOT.jar ./ "https://ci.codemc.org/job/AuthMe/job/AuthMeBungee/" firstMatch "AuthMeBungee-.*\SNAPSHOT.jar"
wget --no-verbose --no-hsts --show-progress --trust-server-names https://ci.codemc.org/job/AuthMe/job/AuthMeReloaded/lastSuccessfulBuild/artifact/target/AuthMe-5.5.1-SNAPSHOT.jar
wget --no-verbose --no-hsts --show-progress --trust-server-names https://ci.codemc.org/job/AuthMe/job/AuthMeBungee/lastSuccessfulBuild/artifact/target/AuthMeBungee-2.1.0-SNAPSHOT.jar
wget --no-verbose --no-hsts --show-progress --trust-server-names http://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/modules/ProtocolLib/target/ProtocolLib.jar
#java -jar ../downloadscraper-1.0-SNAPSHOT.jar ./ "https://ci.lucko.me/view/LuckPerms/job/LuckPerms/" firstMatch "LuckPerms-Bukkit-.*\.jar"
wget --no-verbose --no-hsts --show-progress --trust-server-names https://ci.lucko.me/view/LuckPerms/job/LuckPerms/850/artifact/bukkit/build/libs/LuckPerms-Bukkit-4.3.74.jar
wget --no-verbose --no-hsts --show-progress --trust-server-names https://build.true-games.org/job/ProtocolSupport/lastSuccessfulBuild/artifact/target/ProtocolSupport.jar
cd ..

# Prepare and start instances
cp -r ../model/backend .
cd backend
cp ../tmp/paperclip.jar .
cp ../tmp/AuthMe-*.jar ./plugins
cp ../tmp/LuckPerms-*.jar ./plugins
cp ../tmp/ProtocolLib.jar ./plugins
cp ../tmp/ProtocolSupport.jar ./plugins
screen -dmS authme-backend java -Xmx512M -jar paperclip.jar
cd ..

cp -r ../model/lobby .
cd lobby
cp ../tmp/paperclip.jar .
cp ../tmp/AuthMe-*.jar ./plugins
cp ../tmp/LuckPerms-*.jar ./plugins
cp ../tmp/ProtocolLib.jar ./plugins
cp ../tmp/ProtocolSupport.jar ./plugins
screen -dmS authme-lobby java -Xmx512M -jar paperclip.jar
cd ..

cp -r ../model/proxy .
cd proxy
cp ../tmp/Waterfall.jar .
cp ../tmp/AuthMeBungee-*.jar ./plugins
screen -dmS authme-proxy java -Xmx512M -jar Waterfall.jar
cd ..

# Cleanup
rm -rf tmp
