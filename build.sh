#!/bin/bash

# based on https://hub.docker.com/r/frolvlad/alpine-oraclejdk8/
#docker build -t $PREFIX/alpine-glibc alpine-glibc

PREFIX=${DOCKER_PREFIX:-blackbelt}

CWD=`dirname $0`

function build_oracle_jdk {
    JAVA_VERSION="$1"
    JAVA_UPDATE="$2"
    JAVA_BUILD="$3"
    docker build -t "${PREFIX}/oraclejdk${JAVA_VERSION}" --build-arg JAVA_VERSION="${JAVA_VERSION}" --build-arg JAVA_UPDATE="${JAVA_UPDATE}" --build-arg JAVA_BUILD="${JAVA_BUILD}" "${CWD}"
    docker build -t "${PREFIX}/oraclejdk${JAVA_VERSION}:1.${JAVA_VERSION}.0_${JAVA_UPDATE}" --build-arg JAVA_VERSION="${JAVA_VERSION}" --build-arg JAVA_UPDATE="${JAVA_UPDATE}" --build-arg JAVA_BUILD="${JAVA_BUILD}" "${CWD}"
    if [ "x1" == "x${PUSH_DOCKER_IMAGE}" ]
    then
        docker push "${PREFIX}/oraclejdk${JAVA_VERSION}"
    fi
}

build_oracle_jdk $@
