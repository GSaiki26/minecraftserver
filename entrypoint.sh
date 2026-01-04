#!/bin/bash
set -euo pipefail
cd /data || exit 1

MINECRAFT_VERSION="${MINECRAFT_VERSION:-1.21.11}"
FABRIC_LOADER_VERSION="${FABRIC_LOADER_VERSION:-0.18.4}"
FABRIC_INSTALLER_VERSION="${FABRIC_INSTALLER_VERSION:-1.1.1}"
JAVA_XMX="${JAVA_XMX:-1G}"
JAVA_XMS="${JAVA_XMS:-1G}"
VAR_PROPERTY_PREFIX="${VAR_PROPERTY_PREFIX:-MINECRAFT_}"

SOH=$'\x01'

function overwrite_eula() {
    # Verify if env MINECRAFT_EULA exists and file eula.txt also exists.
    if [[ -n "$MINECRAFT_EULA" && -f eula.txt ]]; then
        echo "[CONTAINER] Overwriting EULA..."
        sed -i "s/eula=.*/eula=$MINECRAFT_EULA/g" eula.txt
        echo "[CONTAINER]   EULA changed to $MINECRAFT_EULA."
    fi
}

function overwrite_server_properties() {
    if [[ ! -f "server.properties" ]]; then
        return
    fi

    echo "[CONTAINER] Overwriting server.properties..."
    cp ./server.properties server.properties.temp

    while read -r LINE; do
        LINE=$(echo "$LINE" | tr -d '\r')

        # Verify if line is a k=v.
        if [[ ! $LINE =~ "=" ]]; then
            continue
        fi

        # Get only the real property name.
        PROPERTY="${LINE%=*}"
        PROPERTY_VALUE="${LINE#*=}"

        # Get an env format like to the property. Ex: server-port -> SERVER_PORT
        PROPERTY_ENV_FMT="${PROPERTY^^}"
        PROPERTY_ENV_FMT="${PROPERTY_ENV_FMT//[.-]/_}"

        for VAR_NAME in $(compgen -v "$VAR_PROPERTY_PREFIX"); do
            # Parse the env.
            VAR_NAME_PROPERTY="${VAR_NAME^^}"
            VAR_NAME_PROPERTY="${VAR_NAME_PROPERTY##"$VAR_PROPERTY_PREFIX"}"

            # Check if the property has an env.
            if [[ ! "$PROPERTY_ENV_FMT" == "$VAR_NAME_PROPERTY" ]]; then
                continue
            fi

            # Check if the property value is different than env.
            if [[ "$PROPERTY_VALUE" != "${!VAR_NAME}" ]]; then
                echo "[CONTAINER]   -- $PROPERTY=$PROPERTY_VALUE"
                sed -i "s$SOH^$PROPERTY=.*$SOH$PROPERTY=${!VAR_NAME}$SOH" server.properties.temp
                echo "[CONTAINER]   ++ $PROPERTY=${!VAR_NAME}"
            fi

        done

    done <server.properties

    if [[ -f server.properties.temp ]]; then
        mv server.properties.temp server.properties
    fi

    echo "[CONTAINER]   server.properties updated."
}

function start_server() {
    SERVER_FILE="fabric-server-mc.$MINECRAFT_VERSION-loader.$FABRIC_LOADER_VERSION-launcher.$FABRIC_INSTALLER_VERSION.jar"

    if [[ ! -f "$SERVER_FILE" ]]; then
        curl -fL "https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$FABRIC_LOADER_VERSION/$FABRIC_INSTALLER_VERSION/server/jar" \
            -o "$SERVER_FILE"

        echo "[CONTAINER] Running first-time instance to generate files..."
        java -Xms"$JAVA_XMS" -Xmx"$JAVA_XMX" -jar "$SERVER_FILE" nogui >/dev/null || true
    fi

    overwrite_eula
    overwrite_server_properties

    printf "[CONTAINER] Starting server...\n\n\n"
    exec java -Xms"$JAVA_XMS" -Xmx"$JAVA_XMX" -jar "$SERVER_FILE" nogui
}

start_server
