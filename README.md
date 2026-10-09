# minecraftserver

A minimal Docker image that runs a [Fabric](https://fabricmc.net/) Minecraft server. On first start it downloads the server JAR, agrees to the EULA, and launches — no setup scripts needed outside the container.

---

## Quick start

```bash
docker run -d \
  -p 25565:25565 \
  -v ./data:/data \
  ghcr.io/gsaiki26/minecraftserver
```

Data (world, configs, logs) is stored in `/data` inside the container. Mount a volume there to persist it.

---

## Configuration

All settings are passed as environment variables.

### Versions

| Variable | Default | Description |
|---|---|---|
| `MINECRAFT_VERSION` | `26.3` | Minecraft version |
| `FABRIC_VERSION` | `0.19.5` | Fabric loader version |
| `FABRIC_INSTALLER_VERSION` | `1.1.2` | Fabric installer version |

### JVM

| Variable | Default | Description |
|---|---|---|
| `JAVA_XMS` | `256m` | Initial heap size (`-Xms`) |
| `JAVA_XMX` | `1g` | Maximum heap size (`-Xmx`) |

### EULA

| Variable | Default | Description |
|---|---|---|
| `ACCEPT_EULA` | `true` | Set to `false` to disable automatic EULA acceptance |

By setting `ACCEPT_EULA=true` you agree to the [Minecraft End User License Agreement](https://www.minecraft.net/en-us/eula).

### server.properties

Any `SERVER_*` environment variable is mapped to a `server.properties` key and applied on every start. The mapping rules are:

- Strip the `SERVER_` prefix
- Lowercase the remainder
- `_` → `-` (e.g. `LEVEL_NAME` → `level-name`)
- `__` → `.` (e.g. `RCON__PORT` → `rcon.port`)

**Examples**

```bash
SERVER_LEVEL_NAME=myworld
SERVER_DIFFICULTY=hard
SERVER_RCON__PORT="25575"
SERVER_MAX__PLAYERS="20"
```

---

## Build arguments

| Argument | Default | Description |
|---|---|---|
| `JDK_VERSION` | `25` | OpenJDK version installed in the image |

```bash
docker build --build-arg JDK_VERSION=21 -t minecraftserver .
```

---

## Volumes

| Path | Description |
|---|---|
| `/data` | World data, `server.properties`, `eula.txt`, logs |

---

## Ports

| Port | Protocol | Description |
|---|---|---|
| `25565` | TCP | Minecraft game traffic |

---

## Image

Built on `alpine:3.24`. Multi-platform: `linux/amd64` and `linux/arm64`.

Releases are tagged by version (`v1.2.3`, `v1.2`, `v1`) and published to [ghcr.io/gsaiki26/minecraftserver](https://github.com/GSaiki26/minecraftserver/pkgs/container/minecraftserver).
