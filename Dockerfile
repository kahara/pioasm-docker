FROM ubuntu:20.04 as base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential \
    cmake \
    git \
    openssh-client

RUN mkdir ~/.ssh \
    && ssh-keyscan github.com > ~/.ssh/known_hosts \
    && git clone --depth 1 --branch 1.1.2 https://github.com/raspberrypi/pico-sdk.git

RUN cd pico-sdk \
    && cd tools/pioasm \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make \
    && strip pioasm \
    && mkdir /app \
    && cp pioasm /app

FROM gcr.io/distroless/cc@sha256:c33fbcd3f924892f2177792bebc11f7a7e88ccbc247f0d0a01a812692259503a as target

COPY --from=base /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/
COPY --from=base /app/pioasm /

ENTRYPOINT ["/pioasm"]
