## Prepare Terraria
FROM docker.io/alpine:latest AS prepare
RUN apk add --no-cache curl unzip

RUN mkdir -p /opt/terraria/server/ &&\
    chmod -R 775 /opt/terraria/

WORKDIR /opt/terraria/server/

ARG VANILLA
ARG VERSION

RUN if [ "$VANILLA" != "true" ]; then \
        curl -Lo ./tModLoader.zip https://github.com/tModLoader/tModLoader/releases/download/v${VERSION}/tModLoader.zip &&\
        unzip -o ./tModLoader.zip &&\
        rm ./tModLoader.zip ./serverconfig.txt &&\
        chmod +x ./LaunchUtils/ScriptCaller.sh; \
    else \
        export TRIM=$(echo $VERSION | sed "s/\.//g") &&\
        curl -Lo ./Terraria.zip https://terraria.org/api/download/pc-dedicated-server/terraria-server-${TRIM}.zip &&\
        unzip -jo ./Terraria.zip "${TRIM}/Linux/*" &&\
        rm ./Terraria.zip &&\
        chmod +x ./TerrariaServer*; \
    fi


## Main
FROM docker.io/debian:latest
RUN apt-get update -y &&\
    apt-get install -y tzdata bash gosu procps libicu-dev curl python3 python3-pexpect

RUN mkdir -p /opt/terraria/config/Worlds &&\
    chmod -R 775 /opt/terraria/

COPY --chmod=755 scripts/entrypoint.sh /opt/terraria/
COPY --chmod=755 scripts/variables.py /opt/terraria/
COPY --chmod=755 scripts/server.py /opt/terraria/

COPY --from=prepare /opt/terraria/server/ /opt/terraria/server/

ARG VANILLA
ARG VERSION

ENV TZ="Etc/UTC"
ENV PUID="1000"
ENV PGID="1000"

ENV VANILLA=$VANILLA
ENV VERSION=$VERSION
ENV SERVERCONFIG="0"

EXPOSE 7777

ENTRYPOINT ["/opt/terraria/entrypoint.sh"]

