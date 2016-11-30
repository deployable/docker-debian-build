#!/usr/bin/env bash

set -uexo pipefail
which greadlink >/dev/null 2>/dev/null && readlink=greadlink || readlink=readlink
rundir=$($readlink -f "${0%/*}")
cd "$rundir"

ARG=${1:-build-proxy}

SCOPE="deployable"
NAME="debian-build"
SCOPE_NAME="${SCOPE}/${NAME}"
IMAGE=$(awk 'tolower($1) ~ /^from$/ {print $2}' Dockerfile)
LOCALE="original"
PROXY="http://10.8.8.8:3142"
BUILD_ARGS="" 


pull(){ 
  docker pull "${IMAGE}"
}

build(){
  docker build -t "${SCOPE_NAME}" ${BUILD_ARGS} .
}

locale(){
  BUILD_ARGS="${BUILD_ARGS} --build-arg DOCKER_BUILD_LOCALE=${LOCALE}"
  echo "set BUILD_ARGS: ${BUILD_ARGS}"
}

au(){
  LOCALE=au
  echo "set LOCALE: ${LOCALE}"
}

proxy(){
  BUILD_ARGS="${BUILD_ARGS} --build-arg DOCKER_BUILD_PROXY=${PROXY}"
  echo "set BUILD_ARGS: ${BUILD_ARGS}"
}


pull-build(){
  pull
  build
}

build-au(){
  au 
  locale 
  pull-build
}

build-proxy(){
  proxy
  pull-build
}

build-au-proxy(){
  au
  locale
  proxy
  pull-build
}

clean(){
  docker rmi ${SCOPE_NAME}
}

$ARG

