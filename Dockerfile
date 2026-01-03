FROM debian:trixie-slim AS base
WORKDIR /app

ARG UID=1000
ARG GID=1000
ARG JDK_VERSION=21

RUN groupadd -g ${GID} server \
    && useradd -s /bin/bash -g ${GID} -u ${UID} server \
    && chown -R server /app

RUN apt-get update \
    && apt-get install -y bash curl unzip openjdk-${JDK_VERSION}-jdk \
    && apt-get autoclean -y

ENV MCRCON_VERSION="0.7.2"
ENV MCRCON_FILE="mcrcon-${MCRCON_VERSION}-linux-x86-64-static"
RUN curl -fL "https://github.com/Tiiffi/mcrcon/releases/download/v${MCRCON_VERSION}/${MCRCON_FILE}.zip" \
    -o "${MCRCON_FILE}.zip" \
    && unzip ${MCRCON_FILE}.zip \
    && mv ${MCRCON_FILE}/mcrcon /usr/local/bin/ \
    && rm -rf ${MCRCON_FILE}

COPY --chown=server:server  ./entrypoint.sh .
RUN chmod u+x ./entrypoint.sh

USER server
VOLUME [ "/data" ]
ENTRYPOINT [ "/app/entrypoint.sh" ]
