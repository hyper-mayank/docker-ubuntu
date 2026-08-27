FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    init \
    systemd \
    snapd \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    openssl

RUN apt update -y && apt install -y \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps

RUN apt install software-properties-common -y

RUN add-apt-repository ppa:mozillateam/ppa -y

RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' \
    | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

RUN apt update -y && apt install -y firefox

RUN apt update -y && apt install -y xubuntu-icon-theme

# VNC password: only first 8 characters are used by TigerVNC
RUN mkdir -p /root/.vnc && \
    printf 'mayank11\n' | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# XFCE desktop startup
RUN printf '#!/bin/sh\nxrdb $HOME/.Xresources\nstartxfce4 &\n' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c 'vncserver -localhost no -SecurityTypes VncAuth -geometry 1024x768 && \
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes \
-out /root/self.pem -keyout /root/self.pem && \
websockify -D --web=/usr/share/novnc/ \
--cert=/root/self.pem 6080 localhost:5901 && \
tail -f /dev/null'
