#!/bin/bash

# Cache sudo credentials
sudo echo

# Prepare workdir
rm -rf workdir
mkdir workdir
cd workdir

# Prepare DB
sudo service mysql start
sudo mysql -e "DROP DATABASE authmetest;"
sudo mysql -e "CREATE DATABASE authmetest;"

# Download stuff
mkdir tmp
cd tmp
wget https://papermc.io/ci/job/Paper-1.13/lastSuccessfulBuild/artifact/paperclip.jar
wget https://papermc.io/ci/view/WaterfallMC/job/Waterfall/lastSuccessfulBuild/artifact/Waterfall-Proxy/bootstrap/target/Waterfall.jar
java -jar ../../downloadscraper-1.0-SNAPSHOT.jar ./ "https://ci.codemc.org/job/AuthMe/job/AuthMeReloaded/" firstMatching "AuthMe-.*\SNAPSHOT.jar"
java -jar ../../downloadscraper-1.0-SNAPSHOT.jar ./ "https://ci.codemc.org/job/AuthMe/job/AuthMeBungee/" firstMatching "AuthMeBungee-.*\SNAPSHOT.jar"
wget http://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/modules/ProtocolLib/target/ProtocolLib.jar
java -jar ../../downloadscraper-1.0-SNAPSHOT.jar ./ "https://ci.lucko.me/view/LuckPerms/job/LuckPerms/" firstMatching "LuckPerms-Bukkit-.*\.jar"
wget https://build.true-games.org/job/ProtocolSupport/lastSuccessfulBuild/artifact/target/ProtocolSupport.jar
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
