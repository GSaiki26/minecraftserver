#!/bin/bash

cd /data || mkdir /data && cd /data

MINECRAFT_VERSION="${MINECRAFT_VERSION:-26.3}"
FABRIC_VERSION="${FABRIC_VERSION:-0.19.5}"
FABRIC_INSTALLER_VERSION="${FABRIC_INSTALLER_VERSION:-1.1.2}"

NEOFORGE_VERSION="${NEOFORGE_VERSION:-21.4.111-beta}"

MODLOADER_TYPE="${MODLOADER_TYPE:-neoforge}"

ACCEPT_EULA="${ACCEPT_EULA:-true}"

JAVA_XMS="${JAVA_XMS:-256m}"
JAVA_XMX="${JAVA_XMX:-1g}"

SERVER_FILENAME="server.jar"
NEOFORGE_ARGS_FILE="libraries/net/neoforged/neoforge/$NEOFORGE_VERSION/unix_args.txt"


init_server_fabric() {
    echo "[CONTAINER] Downloading fabric server..."

    wget -O "$SERVER_FILENAME" https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$FABRIC_VERSION/$FABRIC_INSTALLER_VERSION/server/jar || { rm -f "$SERVER_FILENAME"; exit 1; }

    echo "[CONTAINER] Downloaded fabric server..."
}

init_server_neoforge() {
    echo "[CONTAINER] Downloading neoforge server..."

    wget -O "$SERVER_FILENAME" https://maven.neoforged.net/releases/net/neoforged/neoforge/$NEOFORGE_VERSION/neoforge-$NEOFORGE_VERSION-installer.jar || exit 1
    java -jar "$SERVER_FILENAME" --install-server || exit 1

    echo "[CONTAINER] Downloaded neoforge server..."
}

agree_eula() {
    echo "eula=true" > eula.txt
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


case "$MODLOADER_TYPE" in
    fabric)
        [[ -e "$SERVER_FILENAME" ]] || init_server_fabric
        SERVER_JAVA_ENTRYPOINT="-jar $SERVER_FILENAME"
        ;;
    neoforge)
        [[ -e "$NEOFORGE_ARGS_FILE" ]] || init_server_neoforge
        SERVER_JAVA_ENTRYPOINT="@$NEOFORGE_ARGS_FILE"
        ;;
    *)
        echo "[CONTAINER] Unknown MODLOADER_TYPE: $MODLOADER_TYPE" >&2
        exit 1
        ;;
esac

if [[ "$ACCEPT_EULA" == "true" ]]; then
    agree_eula
fi

if [[ ! -e "user_jvm_args.txt" ]]; then
    touch user_jvm_args.txt
fi

touch server.properties
override_props
exec java @user_jvm_args.txt -Xms"$JAVA_XMS" -Xmx"$JAVA_XMX" $SERVER_JAVA_ENTRYPOINT --nogui
