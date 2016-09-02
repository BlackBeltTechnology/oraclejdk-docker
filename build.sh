#!/bin/bash

set -e

# based on https://hub.docker.com/r/frolvlad/alpine-oraclejdk8/
#docker build -t $PREFIX/alpine-glibc alpine-glibc

PREFIX=${DOCKER_PREFIX:-blackbelt}

CWD=`dirname $0`
ARTIFACTS_DIR="${CWD}/artifacts"

function check_command {
    which "$1" > /dev/null 2>&1
    if [ "$?" -ne 0 ]
    then
        echo -e "Command '$1' should be installed and added to PATH"
        exit 1
    fi
}

check_command mvn

mkdir -p "${ARTIFACTS_DIR}"

#mvn clean install -f "${CWD}/jcollectd/pom.xml"

cp ${CWD}/jcollectd/target/jcollectd-*.jar "${ARTIFACTS_DIR}/jcollectd.jar"
tar cvzf "${ARTIFACTS_DIR}/jcollectd-conf.tar.gz" -C "${CWD}/jcollectd/etc/" .

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
