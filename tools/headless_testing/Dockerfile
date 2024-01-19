FROM ubuntu:devel

WORKDIR /bar

# Install prerequisites for pr-downloader
RUN apt-get update && \
    apt-get install -y build-essential cmake pkg-config git libcurl4-openssl-dev zlib1g-dev #libboost-test-dev

# Build pr-downloader
WORKDIR /pr-downloader
RUN git clone --quiet --depth=1 --jobs 8 --recurse-submodules https://github.com/beyond-all-reason/pr-downloader .
RUN mkdir builddir && \
    cd builddir && \
    cmake .. && \
    cmake --build .

WORKDIR /bar

RUN mkdir -p maps games engine

RUN git clone --quiet --depth=1 --jobs 8 https://github.com/beyond-all-reason/beyond-all-reason games/BAR.sdd

RUN /pr-downloader/builddir/src/pr-downloader filesystem-writepath "/bar" download-map "Full Metal Plate 1.5"

RUN apt-get update && \
    apt-get install -y curl jq 7zip

COPY download-engine.sh /bar/
RUN ./download-engine.sh
