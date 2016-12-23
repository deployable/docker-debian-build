#!/usr/bin/env bash


# Setup
set -uexo pipefail
which greadlink >/dev/null 2>/dev/null && readlink=greadlink || readlink=readlink
rundir=$($readlink -f "${0%/*}")
cd "$rundir"


# Default params to `build-proxy`
[ -z ${1:-} ] && set -- build-proxy "$@"


# Properties

SCOPE="deployable"
NAME="debian-build"
SCOPE_NAME="${SCOPE}/${NAME}"
#IMAGE=$(awk 'tolower($1) ~ /^from$/ {print $2}' Dockerfile)
IMAGE=debian
LOCALE="original"
PROXY="http://10.8.8.8:3142"
if [ -z "${BUILD_ARGS:-}" ]; then
 BUILD_ARGS=""
fi


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

label_vcsref(){
  git_revision=$(git rev-parse --verify HEAD)
  perl -i -pane 's!org\.label-schema\.vcs-ref.*!org.label-schema.vcs-ref = "'$git_revision'" \\!g;' Dockerfile
}

label_version(){
  local version=$(date +%Y%m%d)
  perl -i -pane 's!org\.label-schema\.version.*!org.label-schema.version = "'$version'" \\!g;' Dockerfile
}


# Runit
"$@"

