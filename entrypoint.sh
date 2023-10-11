#! /bin/bash

# Functions
function start {
  echo "-Xmx$XMX -Xms$XMS" > user_jvm_args.txt
  ./run.sh nogui;
}

# Code
# Check if the server folder is reacheable
cd /server
if [[ (! -d "/server" || ! -w "/server") ]]; then
  echo "The /server folder is not reacheable. Please check it permissions."
  exit 1
fi

# Define the start command and set the XMX and XMS.
printf "Starting server with $(java --version)\n\n";

# Check if the server already is ready.
if [[ (-f "./eula.txt" && -r "./eula.txt") ]]; then
  # Start the server.
  echo "Server already exists, running it...";
  start;
fi

# The server is new. Check if the forge envs were provided.
if [[ ("$FORGE_MINECRAFT_VERSION" != "" && "$FORGE_VERSION" != "") || "$FORGE_SERVER_URL" != "" ]]; then
  SERVER_TO_DOWNLOAD=$FORGE_SERVER_URL
  if [[ ("$FORGE_MINECRAFT_VERSION" != "" && "$FORGE_VERSION" != "") ]]; then
    VERSION="$FORGE_MINECRAFT_VERSION-$FORGE_VERSION"
    SERVER_TO_DOWNLOAD="https://maven.minecraftforge.net/net/minecraftforge/forge/$VERSION/forge-$VERSION-installer.jar"
  fi

  echo "Installing forge server from: $SERVER_TO_DOWNLOAD";
  wget -q $SERVER_TO_DOWNLOAD -O ./server.jar;

  # Install the server.
  java -jar ./server.jar --installServer /server;
  rm server.jar* run.bat;
  start;
  return
fi

# The forge was not defined. So the vanilla was choosen.
if [ "$SERVER_URL" != "" ]; then
  echo "Installing vanilla server from: $SERVER_URL";
  wget -q $SERVER_URL -O ./server.jar;
  printf "#! /bin/bash\njava -jar @user_jvm_args.txt ./server.jar" > ./run.sh;
  chmod u+x ./run.sh;
  start;
  return
fi

echo "Any version from minecraft was specified. Please check your environment variables."
