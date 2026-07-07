# docker-java-apples

A Docker container running Ubuntu 18.04 with XFCE, TigerVNC, Firefox 45 ESR, and Oracle JDK 8 for accessing legacy Java applets (IPMI/iDRAC/KVM consoles). Exposes both native VNC (port 5901) and a browser-based noVNC interface (port 6080).

## Key files

- `Dockerfile` — builds the image; installs XFCE, VNC, Firefox 45 ESR, noVNC/websockify, and the Oracle JDK
- `docker-compose.yml` — runs the container with ports 5901 and 6080 exposed
- `setup.sh` — one-time script to download and verify `jdk-8u202-linux-x64.tar.gz` before building
- `java_config/deployment.properties` — Java deployment settings (security level, etc.)
- `java_config/exception.sites` — list of sites allowed to run Java applets
- `firefox_theme/firefox.desktop` — desktop shortcut placed on the XFCE desktop

## Workflow

```bash
# 1. Download and verify the JDK package (one-time)
./setup.sh

# 2. Build and start
docker-compose up --build

# 3. Connect
#    Browser:     http://localhost:6080/vnc.html
#    VNC client:  localhost:5901  (password: docker)

# 4. Stop
docker-compose down
```

## Adding allowed Java sites

Edit `java_config/exception.sites` before building — one URL per line. Rebuild the image after changes.

## Platform note

The image targets `linux/amd64`. On Apple Silicon, Docker Desktop's Rosetta emulation handles this automatically.
