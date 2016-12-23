#!/usr/bin/env bash


# Setup
set -uexo pipefail
which greadlink >/dev/null 2>/dev/null && readlink=greadlink || readlink=readlink
rundir=$($readlink -f "${0%/*}")
cd "$rundir"


# Command to run

ARG=${1:-build-proxy}
shift


# Properties

SCOPE="deployable"
NAME="debian-build"
SCOPE_NAME="${SCOPE}/${NAME}"
#IMAGE=$(awk 'tolower($1) ~ /^from$/ {print $2}' Dockerfile)
IMAGE=debian
LOCALE="original"
PROXY="http://10.8.8.8:3142"
#BUILD_ARGS="" 


# Commands

pull(){ 
  docker pull "${IMAGE}"
}

build(){
  build_one latest
}

build_one(){
  local tag=$1
  rm -f Dockerfile.$tag
  perl -pe 's/debian:latest/debian:'$tag'/' Dockerfile > Dockerfile.$tag
  docker build --build-arg DOCKER_BUILD_PROXY="${PROXY}" -t ${SCOPE_NAME}:$tag ${BUILD_ARGS} -f Dockerfile.$tag .
}

build_all(){
  build_one wheezy
  build_one 7
  build_one jessie
  build_one 8
  build_one latest
  build_one stretch
  build_one testing
  build_one sid
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

git_tag(){
  local build_tag=${1:-$(date +%Y%m%d)}
  git tag -f "${build_tag}" && git push -f --tags
}

clean(){
  docker rmi ${SCOPE_NAME}
}


# Orchestration

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


# Runit

$ARG "$@"

