#!/bin/bash

cd /data || mkdir /data && cd /data

MINECRAFT_VERSION="${MINECRAFT_VERSION:-26.3}"
FABRIC_VERSION="${FABRIC_VERSION:-0.19.5}"
FABRIC_INSTALLER_VERSION="${FABRIC_INSTALLER_VERSION:-1.1.2}"

ACCEPT_EULA="${ACCEPT_EULA:-true}"

JAVA_XMS="${JAVA_XMS:-256m}"
JAVA_XMX="${JAVA_XMX:-1g}"

SERVER_FILENAME="server.jar"

init_server() {
    echo "[CONTAINER] Downloading fabric server..."

    wget -O "$SERVER_FILENAME" https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$FABRIC_VERSION/$FABRIC_INSTALLER_VERSION/server/jar
    java -jar "$SERVER_FILENAME" --initSettings

    echo "[CONTAINER] Downloaded fabric server..."
}

agree_eula() {
    sed -i "s/eula=false/eula=true/g" eula.txt
}

override_props() {
    while IFS='=' read -r NAME VALUE; do
        [[ $NAME == SERVER_* ]] || continue

        # SERVER_LEVEL_NAME -> level-name
        # SERVER_RCON__PORT -> rcon.port   (double underscore = dot)
        PROPERTY="${NAME#SERVER_}"
        PROPERTY="${PROPERTY,,}"
        PROPERTY="${PROPERTY//__/.}"
        PROPERTY="${PROPERTY//_/-}"

        echo "[CONTAINER] Overwriting server property $PROPERTY..."
        sed -i "/^$PROPERTY=/d" server.properties
        echo "$PROPERTY=$VALUE" >> server.properties
        echo "[CONTAINER] Overwrote server property $PROPERTY with $VALUE"

    done < <(printenv)
}


if [[ ! -e "$SERVER_FILENAME" ]]; then
    init_server
fi

if grep -q "eula=false" eula.txt && [[ "$ACCEPT_EULA" == "true" ]]; then
    agree_eula
fi

override_props
exec java -Xms"$JAVA_XMS" -Xmx"$JAVA_XMX" -jar "$SERVER_FILENAME"  --nogui
