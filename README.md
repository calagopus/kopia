![Calagopus Logo](https://calagopus.com/fulllogo.svg)

# Kopia Multi-Architecture Builds

Automated multi-architecture builds of [Kopia](https://github.com/kopia/kopia), a fast and secure open-source backup/restore tool, for various platforms.

## Supported Architectures

- **x86_64** (amd64) - Intel/AMD 64-bit
- **aarch64** (arm64) - ARM 64-bit
- **armv7** (arm/v7) - ARM 32-bit (hard-float)
- **ppc64le** - PowerPC 64-bit Little Endian
- **s390x** - IBM System z
- **riscv64** - RISC-V 64-bit

## Docker Usage

```bash
# Pull the latest version
docker pull ghcr.io/calagopus/kopia:latest

# Show kopia help
docker run --rm ghcr.io/calagopus/kopia:latest --help

# Run a repository connect/backup (mount host config + data)
docker run --rm \
  -v "$HOME/.config/kopia:/app/config" \
  -v "$PWD:/data" \
  ghcr.io/calagopus/kopia:latest snapshot create /data
```

## Build Schedule

- Automatic builds run every Sunday at 00:00 UTC
- Manual builds can be triggered via GitHub Actions
- Versions track upstream [kopia/kopia](https://github.com/kopia/kopia) releases

## Architecture Mapping

| Docker Platform | Binary Name | Common Name      |
|-----------------|-------------|------------------|
| linux/amd64     | x86_64      | Intel/AMD        |
| linux/arm64     | aarch64     | ARM 64-bit       |
| linux/arm/v7    | armv7       | ARM 32-bit       |
| linux/ppc64le   | ppc64le     | PowerPC          |
| linux/s390x     | s390x       | IBM Z            |
| linux/riscv64   | riscv64     | RISC-V           |

## How It Works

Kopia is a pure-Go application, so the [`Dockerfile`](./Dockerfile) cross-compiles
the binary from the build platform (`$BUILDPLATFORM`) for each target architecture
with `CGO_ENABLED=0`. This avoids slow QEMU emulation during compilation while still
producing a proper multi-arch image manifest. Built binaries are also extracted and
attached to GitHub releases.

## Contributing

Issues and pull requests are welcome. This repository primarily automates building upstream [kopia/kopia](https://github.com/kopia/kopia) releases.
