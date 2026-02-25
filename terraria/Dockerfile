FROM docker.io/debian:latest
# These come from the workflow --build-args
ARG VERSION
ARG VERSIONTRIM

RUN mkdir -p /opt/terraria/server/ &&\
    mkdir -p /opt/terraria/config/Worlds

COPY scripts/entrypoint.sh /opt/terraria/
COPY scripts/variables.sh /opt/terraria/
COPY scripts/server.sh /opt/terraria/
COPY scripts/inject.sh /usr/local/bin/inject

RUN chmod -R 775 /opt/terraria/ &&\
    chmod +x /opt/terraria/entrypoint.sh &&\
    chmod +x /opt/terraria/server.sh &&\
    chmod 755 /usr/local/bin/inject

WORKDIR /opt/terraria/server/

RUN apt-get update -y &&\
    apt-get install -y curl unzip

RUN curl -Lo ./Terraria.zip https://terraria.org/api/download/pc-dedicated-server/terraria-server-${VERSIONTRIM}.zip &&\
    unzip -jo ./Terraria.zip "${VERSIONTRIM}/Linux/*" &&\
    rm ./Terraria.zip &&\
    chmod +x ./TerrariaServer*

RUN apt-get update -y &&\
    apt-get install -y netcat-openbsd bash gosu procps libicu-dev tmux

ENV PUID="1000"
ENV PGID="1000"

ENV VERSION=$VERSION

ENV SERVERCONFIG="0"

ENV AUTOCREATE=""
ENV BANLIST="banlist.txt"
ENV DIFFICULTY="0"
ENV LANGUAGE="en-US"
ENV MAXPLAYERS="8"
ENV MODPACK=""
ENV MOTD=""
ENV NPCSTREAM="15"
ENV PASSWORD=""
ENV PORT="7777"
ENV PRIORITY="1"
ENV SECURE="1"
ENV SEED=""
ENV UPNP="0"
ENV WORLDNAME="World"

ENV BIOMESPREAD_SETFROZEN="2"
ENV GODMODE="2"
ENV INCREASEPLACEMENTRANGE="2"
ENV RAIN_SETFROZEN="2"
ENV RAIN_SETSTRENGTH="2"
ENV SETDIFFICULTY="2"
ENV SETSPAWNRATE="2"
ENV TIME_SETDAWN="2"
ENV TIME_SETDUSK="2"
ENV TIME_SETFROZEN="2"
ENV TIME_SETMIDNIGHT="2"
ENV TIME_SETNOON="2"
ENV TIME_SETSPEED="2"
ENV WIND_SETFROZEN="2"
ENV WIND_SETSTRENGTH="2"

EXPOSE 7777

ENTRYPOINT ["/opt/terraria/entrypoint.sh"]

