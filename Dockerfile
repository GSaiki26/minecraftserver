# Basics
FROM debian:12-slim
WORKDIR /app

ENV JDK_URL "https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb"
ENV JDK_FILE "jdk-21_linux-x64_bin.deb"
ENV TZ="America/Sao_Paulo"

# Update the container
RUN apt-get update; apt-get upgrade -y;
RUN apt-get install -y bash tar tzdata wget;
RUN date;

# Download the jdk
RUN wget $JDK_URL;
RUN dpkg -i $JDK_FILE;

# Create the user
RUN useradd user;
RUN mkdir /server; chown user /server;
USER user

# Run the entrypoint
COPY --chown=user ./entrypoint.sh .

WORKDIR /server
ENTRYPOINT /app/entrypoint.sh
