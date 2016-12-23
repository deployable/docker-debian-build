FROM debian:latest

#     docker build -t deployable/debian-build --build-arg DOCKER_BUILD_PROXY=http://10.8.8.8:3142 --build-arg DOCKER_BUILD_LOCALE=au .

# Source build packages locally
ARG DOCKER_BUILD_PROXY
ENV DOCKER_BUILD_PROXY $DOCKER_BUILD_PROXY

# Fix ipv6 wierdness with new debian mirror resolver
RUN echo 'precedence ::ffff:0:0/96  100' > /etc/gai.conf

# New deb mirror removes need for this
#ARG DOCKER_BUILD_LOCALE=original
#RUN cp /etc/apt/sources.list /etc/apt/sources.list.original
#COPY apt.sources.list.au /etc/apt/sources.list.au
#COPY apt.sources.list.uk /etc/apt/sources.list.uk
#COPY apt.sources.list.$DOCKER_BUILD_LOCALE /etc/apt/sources.list

# Turn off documentation
COPY dpkg.01_nodoc /etc/dpkg/dpkg.conf.d/01_nodoc

# Install common build tools
RUN set -uex; \
    export http_proxy=${HTTP_PROXY-${DOCKER_BUILD_PROXY}}; \
    apt-get update; \
    apt-get install --no-install-suggests --no-install-recommends -y \
      make \
      curl \
      wget \
      gcc \
      g++ \
      libc6-dev \
      libtool \
      autoconf \
      automake \
      libssl-dev; \
    apt-get clean all


label org.label-schema.name = "deployable/debian-build" \
      org.label-schema.version="1.0.0" \
      org.label-schema.vendor="Deployable" \
      org.label-schema.docker.cmd="docker run -ti deployable/debian-build \
      org.label-schema.url="https://github.com/deployable/docker-debian-build" \
      org.label-schema.vcs-url="https://github.com/deployable/docker-debian-build.git" \
      org.label-schema.vcs-ref = "b4cac33cff2491440c3c010aabc885387ade425f" \
      org.label-schema.schema-version="1.0" 


