FROM ubuntu:devel

WORKDIR /bar

# Install prerequisites for pr-downloader
RUN apt-get update && \
    apt-get install -y curl jq 7zip

WORKDIR /bar

RUN mkdir -p maps games engine

COPY download-engine.sh /bar/
RUN ./download-engine.sh

RUN /bar/engine/*/pr-downloader --filesystem-writepath "/bar" download-map "Full Metal Plate 1.5"

COPY ./startscript.txt /bar/
COPY ./start.sh /bar/

ENTRYPOINT /bar/start.sh