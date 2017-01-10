#!/bin/bash

# based on https://hub.docker.com/r/frolvlad/alpine-oraclejdk8/
#docker build -t $PREFIX/alpine-glibc alpine-glibc

PREFIX=${DOCKER_PREFIX:-blackbelt}

CWD=`dirname $0`
ARTIFACTS_DIR="${CWD}/artifacts"

MAVEN_COMMAND='mvn'
MAVEN_MAJOR=3
MAVEN_VERSION=3.3.9

COLLECTD_VERSION='1.0.0'
COLLECTD_SOURCES="https://github.com/BlackBeltTechnology/collectd/archive/${COLLECTD_VERSION}.zip"

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

wget -O "${CWD}/collectd.zip" "${COLLECTD_SOURCES}"

rm -Rf "${CWD}/collectd-${COLLECTD_VERSION}"/
unzip "${CWD}/collectd.zip" -d "${CWD}"
rm -f "${CWD}/collectd.zip"

${MAVEN_COMMAND} clean install -Dmaven.test.skip=true -f "${CWD}/collectd-${COLLECTD_VERSION}/pom.xml"
rm -Rf /tmp/apache-maven*

cp ${CWD}/collectd-${COLLECTD_VERSION}/collectd-jmx-agent/target/collectd-*-jar-with-dependencies.jar "${ARTIFACTS_DIR}/collectd.jar"
tar cvzf "${ARTIFACTS_DIR}/collectd-conf.tar.gz" -C "${CWD}/collectd-${COLLECTD_VERSION}/collectd-jmx-agent/src/main/config/" .

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
