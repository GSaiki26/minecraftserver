# Minecraft Server Image
[![Project publish](https://github.com/GSaiki26/minecraftserver/actions/workflows/docker-publish.yaml/badge.svg?branch=master)](https://github.com/GSaiki26/minecraftserver/actions/workflows/docker-publish.yaml)

The [minecraft server image](https://hub.docker.com/r/gsaiki26/minecraftserver) is a docker image that has the only objetive to start a Vanilla/Forge server. It also has an [repository](https://github.com/GSaiki26/minecraftserver-image).

In order to create your own server, you `need` to create an environment file. In the root folder from the repository has a file named `server.env`, an env example.

## Environment Variables
The current environment varibles are:
* `XMS` - It'll define the minimum RAM to run the server;
* `XMX` - It'll define the maximum RAM to run the server;
* `SERVER_URL` - The direct URL from the server to download;
* `FORGE_SERVER_URL` - The direct URL from the Forge server to download;
* `FORGE_MINECRAFT_VERSION` - The minecraft version to be used to download the forge;
* `FORGE_VERSION` - The forge version to be downloaded.

The fields dont need necessarilly be defined. Check below:
* ( Vanilla ) If you want a vanilla server, just insert the direct url into the `SERVER_URL` field;
* ( Forge ) define the `FORGE_MINECRAFT_VERSION` and the `FORGE_VERSION` to download. Otherwise, you can simply insert the direct url from the installer in the `FORGE_SERVER_URL`.
* ( Custom ) If you want your simple .jar file, you can insert the direct link on `VANILLA_SERVER_URL` environment variable, or just replace the ./server.jar file that's on `/server` folder. The main command can be found in the script: `./run.sh`.

``Obs``: Before, the minecraft had a simple link that could replace the game's version, but currently it uses a hash, making impossible ( without mapping ) to dynamically download the desired version.

## Backup
The backup can be defined as cronjobs in the container. Each time the container is started, a `crontab` file may be created on `/server` folder ( if not exists ) with a simple backup example.
The example's cronjob create a copy of the "world" ( default name from server's world ) to `/backup/${date}`.

``Obs``: You may want to create a command to delete the lasts X saved worlds, because the example cronjob just create backups, it doesn't erase.

## Volumes
The server folder containing all the contents from your server can be found on `/server`.
The server's folder containing all the backups, by default, can be found on `/backup`.
