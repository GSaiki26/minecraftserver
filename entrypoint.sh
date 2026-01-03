#!/bin/bash
set -euo pipefail
cd /data || exit 1

MINECRAFT_VERSION="${MINECRAFT_VERSION:-1.21.11}"
FABRIC_LOADER_VERSION="${FABRIC_LOADER_VERSION:-0.18.4}"
FABRIC_INSTALLER_VERSION="${FABRIC_INSTALLER_VERSION:-1.1.1}"
JAVA_XMX="${JAVA_XMX:-1G}"
JAVA_XMS="${JAVA_XMS:-1G}"

SERVER_FILE="fabric-server-mc.$MINECRAFT_VERSION-loader.$FABRIC_LOADER_VERSION-launcher.$FABRIC_INSTALLER_VERSION.jar"

if [[ ! -f "$SERVER_FILE" ]]; then
    curl -fL "https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$FABRIC_LOADER_VERSION/$FABRIC_INSTALLER_VERSION/server/jar" \
        -o "$SERVER_FILE"
fi

exec java -Xms"$JAVA_XMS" -Xmx"$JAVA_XMX" -jar "$SERVER_FILE" nogui
