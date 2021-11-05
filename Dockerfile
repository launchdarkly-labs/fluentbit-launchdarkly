FROM amd64/debian:buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    cmake \
    make \
    tar \
    libssl-dev \
    libsasl2-dev \
    pkg-config \
    gnupg \
    luarocks



RUN curl -L https://packages.fluentbit.io/fluentbit.key | apt-key add - && echo "deb https://packages.fluentbit.io/debian/buster buster main" >> /etc/apt/sources.list && apt-get update &&  apt-get install -y td-agent-bit

COPY ./lib/*.so /usr/local/lib/
COPY ./include/launchdarkly/ /usr/local/include/launchdarkly/
COPY ./lua-server-sdk-1.1.0/ /usr/local/src/lua-server-sdk-1.1.0
COPY ./fluentbit.conf /etc/td-agent-bit/launchdarkly.conf
COPY ld.lua /opt/fluentbit/launchdarkly.lua
RUN cd /usr/local/src/lua-server-sdk-1.1.0 && luarocks make launchdarkly-server-sdk-1.0-0.rockspec
CMD ["/opt/td-agent-bit/bin/td-agent-bit", "-c", "/etc/td-agent-bit/launchdarkly.conf"]


