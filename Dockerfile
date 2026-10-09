FROM alpine:3.24
WORKDIR /var/lib/minecraftserver

ARG JDK_VERSION=25

RUN apk add --update --no-cache bash "openjdk$JDK_VERSION-jdk" wget

RUN adduser -Du 1000 server && chown -R server:server .
COPY --chown=server:server ./entrypoint.sh .

RUN chmod u+x entrypoint.sh
ENTRYPOINT ["/var/lib/minecraftserver/entrypoint.sh"]
