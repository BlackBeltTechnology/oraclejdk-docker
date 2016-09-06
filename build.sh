#!/bin/bash

# based on https://hub.docker.com/r/frolvlad/alpine-oraclejdk8/
#docker build -t $PREFIX/alpine-glibc alpine-glibc

PREFIX=${DOCKER_PREFIX:-blackbelt}

CWD=`dirname $0`
ARTIFACTS_DIR="${CWD}/artifacts"

MAVEN_COMMAND='mvn'
MAVEN_MAJOR=3
MAVEN_VERSION=3.3.9

function check_command {
    which "$1" > /dev/null 2>&1
    if [ "$?" -ne 0 ]
    then
        wget -O /tmp/apache-maven.tar.gz https://www.apache.org/dist/maven/maven-${MAVEN_MAJOR}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
        tar xf /tmp/apache-maven.tar.gz -C /tmp
        MAVEN_COMMAND="`ls -ad /tmp/apache-maven*/`bin/mvn"
    fi
}

check_command mvn

mkdir -p "${ARTIFACTS_DIR}"

set -e

${MAVEN_COMMAND} clean install -Dmaven.test.skip=true -f "${CWD}/jcollectd/pom.xml"

rm -Rf /tmp/apache-maven*

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

