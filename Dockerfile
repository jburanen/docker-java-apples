# syntax=docker/dockerfile:1
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ARG VNC_PASSWORD=docker

RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal tightvncserver wget curl sudo \
    openjdk-8-jre icedtea-netx firefox \
    libasound2 libgtk2.0-0 libdbus-glib-1-2 libxt6 libxss1 libnss3 libxrender1 libxcomposite1 \
    libxrandr2 libxi6 libxcursor1 libxinerama1 xvfb gtk2-engines-pixbuf autocutsel \
    novnc websockify \
    && apt-get clean

RUN apt-get purge -y gvfs gvfs-backends gvfs-daemons

# Allow legacy IPMI/iDRAC firmware that signs JARs with MD5/SHA1/weak RSA
# and negotiates weak TLS ciphers. Java will still negotiate strong ciphers
# with modern servers — it uses whatever the server offers.
RUN sed -i \
    -e 's/^jdk.jar.disabledAlgorithms=.*/jdk.jar.disabledAlgorithms=/' \
    -e 's/^jdk.tls.disabledAlgorithms=.*/jdk.tls.disabledAlgorithms=/' \
    /etc/java-8-openjdk/security/java.security

# Create a user
RUN useradd -s /bin/bash -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

RUN mkdir -p /home/docker/.java/deployment /home/docker/.java/deployment/security/
COPY java_config/deployment.properties /home/docker/.java/deployment/
COPY java_config/exception.sites /home/docker/.java/deployment/security/

RUN touch /home/docker/.Xauthority && chown docker:docker /home/docker/.Xauthority

# Create Firefox shortcut on desktop
RUN mkdir /home/docker/.icons/ /home/docker/Desktop
COPY firefox_theme/firefox.desktop /home/docker/Desktop
COPY firefox_theme/firefox.png /home/docker/.icons/
RUN chown -R docker:docker /home/docker/ \
    && chmod +x /home/docker/Desktop/firefox.desktop

USER docker
WORKDIR /home/docker

# Set up VNC
RUN mkdir -p /home/docker/.vnc && \
    echo "${VNC_PASSWORD}" | vncpasswd -f > /home/docker/.vnc/passwd && \
    chmod 600 /home/docker/.vnc/passwd && \
    echo '#!/bin/sh\nautocutsel -fork &' > /home/docker/.vnc/xstartup && \
    echo '\nstartxfce4 &' >> /home/docker/.vnc/xstartup && \
    chmod +x /home/docker/.vnc/xstartup

RUN echo 'ulimit -c unlimited' >> /home/docker/.bashrc

ENV USER=docker

# Expose VNC and noVNC web ports
EXPOSE 5901 6080

# Start VNC server and noVNC web proxy, keep container alive via log tail
CMD bash -c "rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 && \
    vncserver :1 -geometry 1280x800 -depth 24 && \
    websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5901 & \
    tail -F /home/docker/.vnc/*.log"
