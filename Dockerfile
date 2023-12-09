FROM docker.io/frolvlad/alpine-glibc:latest
# VERSION comes from the workflow --build-args
# VERSIONFIX is VERSION without periods so it can be used in the URL
ARG TERRARIAVERSION
ARG TERRARIAVERSIONFIX
ARG TSHOCKVERSION

RUN apk add --no-cache bash grep curl unzip icu-dev tmux jq netcat-openbsd
# Alternatives for security
RUN apk add --no-cache openssl=3.1.4-r1

RUN mkdir -p /opt/terraria/server/ &&\
    mkdir -p /opt/terraria/config/ModPacks &&\
    mkdir -p /opt/terraria/config/Worlds

COPY entrypoint.sh /opt/terraria/
COPY variables.sh /opt/terraria/
COPY inject.sh /usr/local/bin/inject

RUN chmod -R 755 /opt/terraria/ &&\
    chmod +x /opt/terraria/entrypoint.sh &&\
    chmod 755 /usr/local/bin/inject

WORKDIR /opt/terraria/server/

RUN curl -Lo ./Terraria.zip https://terraria.org/api/download/pc-dedicated-server/terraria-server-${TERRARIAVERSIONFIX}.zip

RUN unzip -jo ./Terraria.zip "${TERRARIAVERSIONFIX}/Linux/*" &&\
    rm ./Terraria.zip

RUN chmod +x ./TerrariaServer*

ENV TERRARIAVERSION=$TERRARIAVERSION
ENV TSHOCKVERSION=$TSHOCKVERSION

ENV SERVERCONFIG="0"

ENV AUTOCREATE="2"
ENV DIFFICULTY="0"
ENV BANLIST="banlist.txt"
ENV LANGUAGE="en-US"
ENV MAXPLAYERS="8"
ENV MODPACK=""
ENV MOTD=""
ENV NPCSTREAM="15"
ENV PASSWORD=""
ENV PRIORITY="1"
ENV SECURE="1"
ENV SEED=""
ENV UPNP="0"
ENV WORLDNAME="World"

ENTRYPOINT ["/opt/terraria/entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=5s --retries=2 CMD nc -vz 127.0.0.1 7777 || exit 1
