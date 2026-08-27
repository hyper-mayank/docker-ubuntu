FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install desktop, VNC, noVNC and required utilities
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    xubuntu-icon-theme \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    openssl \
    sudo \
    xterm \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    software-properties-common \
    init \
    systemd \
    snapd \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install Firefox
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt update -y && \
    apt install -y firefox && \
    rm -rf /var/lib/apt/lists/*

# Create VNC configuration directory
RUN mkdir -p /root/.vnc

# VNC password
# NOTE: TigerVNC uses only the first 8 characters
RUN printf 'mayank11\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# XFCE startup script
RUN printf '#!/bin/sh\nxrdb "$HOME/.Xresources" 2>/dev/null || true\nstartxfce4 &\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# X authority file
RUN touch /root/.Xauthority

# Expose VNC and noVNC
EXPOSE 5901
EXPOSE 6080

# Start VNC + noVNC
CMD bash -c '\
    vncserver -localhost no \
    -SecurityTypes VncAuth \
    -geometry 1024x768 \
    -depth 24 && \
    openssl req -new -subj "/C=IN" -x509 -days 365 -nodes \
    -out /root/self.pem \
    -keyout /root/self.pem && \
    websockify -D \
    --web=/usr/share/novnc/ \
    --cert=/root/self.pem \
    6080 localhost:5901 && \
    tail -f /dev/null'
