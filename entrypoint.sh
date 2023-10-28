#! /bin/bash

# Functions
function createCrontabFile {
  if  [[ (! -f "./crontab" ) ]]; then
    echo "The crontab file doesn't exist. Copying from /app...";
    cp /app/crontab ./;
    chmod 700 ./crontab;
  fi

  echo "Installing the crontab file...";
  if [[ (! -r "./crontab") ]]; then
    echo "The crontab file couldn\'t be read. Check it permissions."
    return 1;
  fi

  crontab ./crontab;
}

function installForge {
  # The server is new. Check if the forge envs were provided.
  if [[ ( "$FORGE_MINECRAFT_VERSION" == "" || "$FORGE_VERSION" == "" ) && "$FORGE_SERVER_URL" == "" ]]; then
    return 1;
  fi

  SERVER_TO_DOWNLOAD=$FORGE_SERVER_URL
  if [[ ("$FORGE_MINECRAFT_VERSION" != "" && "$FORGE_VERSION" != "") ]]; then
    VERSION="$FORGE_MINECRAFT_VERSION-$FORGE_VERSION"
    SERVER_TO_DOWNLOAD="https://maven.minecraftforge.net/net/minecraftforge/forge/$VERSION/forge-$VERSION-installer.jar"
  fi

  echo "Installing forge server from: $SERVER_TO_DOWNLOAD";
  wget -O ./server.jar $SERVER_TO_DOWNLOAD;

  # Install the server.
  java -jar ./server.jar --installServer /server;
  rm server.jar* run.bat;
}

function installVanillaOrCustom {
  # The forge was not defined. So the vanilla was choosen.
  if [[ ( "$SERVER_URL" == "") ]]; then
    return 1;
  fi

  echo "Installing vanilla server from: $SERVER_URL";
  wget -O ./server.jar $SERVER_URL;
  printf "#! /bin/bash\njava -jar @user_jvm_args.txt ./server.jar" > ./run.sh;
  chmod u+x ./run.sh;
}

function start {
  echo "-Xmx$XMX -Xms$XMS" > user_jvm_args.txt
  ./run.sh nogui;
}

# Code
# Check if the server folder is reachable
if [[ (! -d "/server" || ! -w "/server") ]]; then
  echo "The /server folder is not reachable. Please check it permissions."
  exit 1
fi

# Define the start command and set the XMX and XMS.
printf "Current container Java:\n$(java --version)\n\n";

# Create the crontab file.
createCrontabFile

# Check if the server already has an eula.
if [[ (! -f "./eula.txt" || ! -r "./eula.txt") ]]; then
  echo "The server's eula wasn't found. Creating..."

  # Try to install forge
  if ! installForge; then
    # Try to install vanilla or custom
    if ! installVanillaOrCustom; then
      echo "Any version from minecraft was specified. Please check your environment variables.";
      exit 1;
    fi
  fi
fi

# Start the server.
echo "Server exists, starting it...";
start;
