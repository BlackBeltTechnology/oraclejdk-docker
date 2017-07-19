#!/bin/bash

# based on https://hub.docker.com/r/frolvlad/alpine-oraclejdk8/
#docker build -t $PREFIX/alpine-glibc alpine-glibc

PREFIX=${DOCKER_PREFIX:-blackbelt}

CWD=`dirname $0`
ARTIFACTS_DIR="${CWD}/artifacts"

COLLECTD_VERSION='1.0.1'
COLLECTD_SOURCES="https://github.com/BlackBeltTechnology/collectd/archive/${COLLECTD_VERSION}.zip"
COLLECTD_URL_BASE='https://repo.maven.apache.org/maven2'
COLLECTD_URL="${COLLECTD_URL_BASE}/hu/blackbelt/collectd-jmx-agent/${COLLECTD_VERSION}/collectd-jmx-agent-${COLLECTD_VERSION}-jar-with-dependencies.jar"

mkdir -p "${ARTIFACTS_DIR}"

set -e

wget -O "${ARTIFACTS_DIR}/collectd.jar" "${COLLECTD_URL}"

function build_oracle_jdk {
    JAVA_VERSION="$1"
    JAVA_UPDATE="$2"
    JAVA_BUILD="$3"
    RND="$4"
    docker build -t "${PREFIX}/oraclejdk${JAVA_VERSION}" --build-arg JAVA_VERSION="${JAVA_VERSION}" --build-arg JAVA_UPDATE="${JAVA_UPDATE}" --build-arg JAVA_BUILD="${JAVA_BUILD}" --build-arg RND="${RND}" "${CWD}"
    docker build -t "${PREFIX}/oraclejdk${JAVA_VERSION}:1.${JAVA_VERSION}.0_${JAVA_UPDATE}" --build-arg JAVA_VERSION="${JAVA_VERSION}" --build-arg JAVA_UPDATE="${JAVA_UPDATE}" --build-arg JAVA_BUILD="${JAVA_BUILD}" --build-arg RND="${RND}" "${CWD}"
    if [ "x1" == "x${PUSH_DOCKER_IMAGE}" ]
    then
        docker push "${PREFIX}/oraclejdk${JAVA_VERSION}"
    fi
}

build_oracle_jdk $@
