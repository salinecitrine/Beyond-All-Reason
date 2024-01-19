FROM ubuntu:devel

WORKDIR /bar

RUN apt-get update && \
    apt-get install -y curl jq 7zip

RUN mkdir -p maps games engine

#COPY --chmod=0755 download-engine.sh /bar/
RUN /bar/tools/headless_testing/download-engine.sh

RUN /bar/engine/*/pr-downloader --filesystem-writepath "/bar" download-map "Full Metal Plate 1.5"

#COPY ./startscript.txt /bar/
#COPY --chmod=0755 ./start.sh /bar/

ENTRYPOINT /bar/tools/headless_testing/start.sh /bar /bar/tools/headless_testing/startscript.txt