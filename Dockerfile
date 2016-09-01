FROM frolvlad/alpine-glibc:alpine-3.3_glibc-2.23
MAINTAINER József Börcsök "jozsef.borcsok@blackbelt.hu"

# JAVA_PACKAGE can be: jdk or server-jre
ARG JAVA_VERSION="8"
ARG JAVA_UPDATE
ARG JAVA_BUILD
ARG JAVA_HOME="/usr/lib/jvm/default"
ARG JAVA_PACKAGE="server-jre"

ENV JAVA_HOME="${JAVA_HOME}"

USER root

RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates unzip && \
    cd "/tmp" && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    tar -xzf "${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" && \
    chown -R root:root "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" && \
    mkdir -p "/usr/lib/jvm" && \
    mv "/tmp/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}" "/usr/lib/jvm/java-${JAVA_VERSION}-oracle" && \
    ls -l "/usr/lib/jvm" && \
    if [ "x7" == "x${JAVA_VERSION}" ]; then \
      wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip" && \
      unzip "UnlimitedJCEPolicyJDK7.zip" && \
      mv -f "/tmp/UnlimitedJCEPolicy/"*.jar "/usr/lib/jvm/java-${JAVA_VERSION}-oracle/jre/lib/security" && \
      rm -rf "/tmp/UnlimitedJCEPolicy"; \
    fi && \
    if [ "x8" == "x${JAVA_VERSION}" ]; then \
      wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" && \
      unzip "jce_policy-8.zip" && \
      mv -f "/tmp/UnlimitedJCEPolicyJDK8/"*.jar "/usr/lib/jvm/java-${JAVA_VERSION}-oracle/jre/lib/security" && \
      rm -rf "/tmp/UnlimitedJCEPolicyJDK8"; \
    fi && \
    ln -s "java-${JAVA_VERSION}-oracle" "${JAVA_HOME}" && \
    ln -s "${JAVA_HOME}/bin/"* "/usr/bin/" && \
    rm -rf "${JAVA_HOME}/"*src.zip && \
    apk del build-dependencies && \
    rm "/tmp/"*
	
RUN mkdir -p "/usr/lib/jvm/collectd"

ADD "artifacts/jcollectd.jar" "/usr/lib/jvm/collectd"
ADD "artifacts/jcollectd-conf.tar.gz" "/usr/lib/jvm/collectd"
