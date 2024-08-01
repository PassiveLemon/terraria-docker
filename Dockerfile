FROM docker.io/frolvlad/alpine-glibc:latest
ARG TARGETARCH
# These come from the workflow --build-args
ARG TERRARIAVERSION
ARG TERRARIAVERSIONFIX

RUN apk add --no-cache bash grep curl unzip icu-dev tmux jq netcat-openbsd

# Mono
RUN if [ "$TARGETARCH" = "arm64" ]; then apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing; fi

RUN mkdir -p /opt/terraria/server/ &&\
    mkdir -p /opt/terraria/config/Worlds

COPY scripts/entrypoint.sh /opt/terraria/
COPY scripts/variables.sh /opt/terraria/
COPY scripts/inject.sh /usr/local/bin/inject

RUN chmod -R 755 /opt/terraria/ &&\
    chmod +x /opt/terraria/entrypoint.sh &&\
    chmod 755 /usr/local/bin/inject

WORKDIR /opt/terraria/server/

RUN curl -Lo ./Terraria.zip https://terraria.org/api/download/pc-dedicated-server/terraria-server-${TERRARIAVERSIONFIX}.zip &&\
    unzip -jo ./Terraria.zip "${TERRARIAVERSIONFIX}/Linux/*" &&\
    rm ./Terraria.zip

RUN chmod +x ./TerrariaServer*

ENV TARGETARCH=$TARGETARCH
ENV TERRARIAVERSION=$TERRARIAVERSION

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

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 CMD nc -vz 127.0.0.1 7777 || exit 1
