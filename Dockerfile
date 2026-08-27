FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install desktop, VNC, noVNC and required tools
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
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install Firefox directly from Mozilla
RUN mkdir -p /opt/firefox && \
    curl -L \
    "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" \
    -o /tmp/firefox.tar.xz && \
    tar -xJf /tmp/firefox.tar.xz -C /opt && \
    ln -s /opt/firefox/firefox /usr/local/bin/firefox && \
    rm -f /tmp/firefox.tar.xz

# VNC configuration directory
RUN mkdir -p /root/.vnc

# VNC password
# TigerVNC traditional VNC password uses first 8 characters
RUN printf 'mayank11\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# XFCE startup
RUN printf '#!/bin/sh\nxrdb "$HOME/.Xresources" 2>/dev/null || true\nstartxfce4 &\n' \
    > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

RUN touch /root/.Xauthority

# Expose ports
EXPOSE 5901
EXPOSE 6080

# Start VNC + noVNC
CMD bash -c '\
    vncserver -localhost no \
    -SecurityTypes VncAuth \
    -geometry 1024x768 \
    -depth 24 && \
    openssl req -new \
    -subj "/C=IN" \
    -x509 \
    -days 365 \
    -nodes \
    -out /root/self.pem \
    -keyout /root/self.pem && \
    websockify -D \
    --web=/usr/share/novnc/ \
    --cert=/root/self.pem \
    6080 localhost:5901 && \
    tail -f /dev/null'
