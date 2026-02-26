# Prepare
FROM docker.io/alpine:latest AS prepare
# VERSIONTRIM comes from the main.yml workflow --build-arg
ARG VERSIONTRIM

RUN mkdir -p /opt/terraria/server/ &&\
    chmod -R 775 /opt/terraria/

WORKDIR /opt/terraria/server/

RUN apk add --no-cache curl unzip

RUN curl -Lo ./Terraria.zip https://terraria.org/api/download/pc-dedicated-server/terraria-server-${VERSIONTRIM}.zip &&\
    unzip -jo ./Terraria.zip "${VERSIONTRIM}/Linux/*" &&\
    rm ./Terraria.zip &&\
    chmod +x ./TerrariaServer*


# Main
FROM docker.io/debian:latest
# VERSION comes from the main.yml workflow --build-arg
ARG VERSION

RUN mkdir -p /opt/terraria/config/Worlds &&\
    chmod -R 775 /opt/terraria/

COPY --chmod=755 scripts/entrypoint.sh /opt/terraria/
COPY --chmod=755 scripts/variables.sh /opt/terraria/
COPY --chmod=755 scripts/server.sh /opt/terraria/
COPY --chmod=755 scripts/inject.sh /usr/local/bin/inject

RUN apt-get update -y &&\
    apt-get install -y netcat-openbsd bash gosu procps libicu-dev tmux

COPY --from=prepare /opt/terraria/server/ /opt/terraria/server/

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

