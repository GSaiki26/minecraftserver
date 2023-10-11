#! /bin/bash

# Functions
function start {
  echo "-Xmx$XMX -Xms$XMS" > user_jvm_args.txt
  ./run.sh nogui;
}

# Code

# Check if the server folder is reacheable
cd /server
if [ ! -d "/server" ] || [ ! -w "/server" ]; then
  echo "The /server folder is not reacheable. Please check it permissions."
  exit 1
fi

# Define the start command and set the XMX and XMS.
printf "Starting server with $(java --version)\n\n";

# Check if the server already is ready.
if [ -f "./eula.txt" ] && [ -r "./eula.txt" ]; then
  # Start the server.
  echo "Server already exists, running it...";
  start;
fi

# The server is new. Check if a forge version was provided.
if [ "$MINECRAFT_VERSION" != "" ] && [ "$FORGE_VERSION" != "" ]; then
  # Download the server.
  VERSION="$MINECRAFT_VERSION-$FORGE_VERSION"
  echo "Installing forge $VERSION...";
  echo "Downloading from: https://maven.minecraftforge.net/net/minecraftforge/forge/$VERSION/forge-$VERSION-installer.jar";
  wget -q "https://maven.minecraftforge.net/net/minecraftforge/forge/$VERSION/forge-$VERSION-installer.jar";

  # Install the server.
  java -jar "./forge-$VERSION-installer.jar" --installServer /server;
  rm forge-*;
  start;
  return
fi

# The forge was not defined. So the vanilla was choosen.
if [ -r "./server.jar" ]; then
  echo "Creating the files to automatically run the server on next boot...";
  printf "#! /bin/bash\njava -jar @user_jvm_args.txt ./server.jar" > ./run.sh;
  start;
  return
fi
