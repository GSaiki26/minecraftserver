# gsaiki26/minecraftserver 🧊
The `gsaiki26/minecraftserver` is a Docker image that wraps the minecraft and RCON client installation.

## Get started 🔥
First of all, the image is hosted by *Github*, so in order to pull it, you must use: `ghcr.io/gsaiki26/minecraftserver`.

The image is based on `debian:trixie-slim` and runs as `1000:1000`.
All server's data is saved into `/data`. If not changed in `server.properties` file, the server will be bound on port `25565/TCP`.

> [!IMPORTANT]
> By the time I'm writing this, the server .jar binary does not listens SIGTERM and SIGINT very well, only if raised by the interactive shell who executed it, so be careful when stopping the server.

### Build configurations
| Variable         | Default | Description                                               |
| ---------------- | :-----: | --------------------------------------------------------- |
| `UID`            | `1000`  | User ID used to run the application inside the container  |
| `GID`            | `1000`  | Group ID used to run the application inside the container |
| `JDK_VERSION`    |  `21`   | Java Development Kit version installed at build time      |
| `MCRCON_VERSION` | `0.7.2` | Version of mcrcon downloaded during image build           |
> [!NOTE]
> To customize these options, you must use `--build-arg` flag when building with `docker build`.

### Runtime configurations
| Variable                   |  Default  | Description                                              |
| -------------------------- | :-------: | -------------------------------------------------------- |
| `MINECRAFT_VERSION`        | `1.21.11` | Minecraft server version to download and run             |
| `FABRIC_LOADER_VERSION`    | `0.18.4`  | Fabric loader version                                    |
| `FABRIC_INSTALLER_VERSION` |  `1.1.1`  | Fabric installer version used to generate the server JAR |
| `JAVA_XMX`                 |   `1G`    | Maximum Java heap size (e.g. 4G)                         |
| `JAVA_XMS`                 |   `1G`    | Initial Java heap size (e.g. 2G)                         |
> [!NOTE]
> Use [https://fabricmc.net/use/server/](https://fabricmc.net/use/server/) to consult the proper versions.
