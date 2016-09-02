FROM frolvlad/alpine-glibc:alpine-3.4
MAINTAINER József Börcsök "jozsef.borcsok@blackbelt.hu"

# JAVA_PACKAGE can be: jdk or server-jre
ARG JAVA_VERSION="8"
ARG JAVA_UPDATE
ARG JAVA_BUILD
ARG JAVA_HOME="/usr/lib/jvm/default"
ARG JAVA_PACKAGE="server-jre"

ENV JAVA_HOME="${JAVA_HOME}"
ENV PLATFORM="linux-x64"
ENV TGZ_FILE_NAME="${JAVA_PACKAGE}-${JAVA_VERSION}u${JAVA_UPDATE}-${PLATFORM}.tar.gz"

USER root

RUN set -e \
    && apk add --no-cache --virtual=build-dependencies wget ca-certificates \
    && wget -O "/tmp/${TGZ_FILE_NAME}" --header "Cookie: oraclelicense=accept-securebackup-cookie;" "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/${TGZ_FILE_NAME}" \
    && if [ "x7" == "x${JAVA_VERSION}" ]; then \
        wget -O "/tmp/jce-policy.zip" --header "Cookie: oraclelicense=accept-securebackup-cookie;" "http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip" \
        && EXPECTED_CHECKSUM_MD5=`echo "<tr><td>server-jre-7u80-linux-x64.tar.gz</td><td>366a145fb3a185264b51555546ce2f87</td></tr>" | sed s/'<\/td><td>'/#/g | sed s/'<\/\?[0-9a-zA-Z]*>'//g | cut -d'#' -f 2` \
    ; fi \
    && if [ "x8" == "x${JAVA_VERSION}" ]; then \
        wget -O "/tmp/jce-policy.zip" --header "Cookie: oraclelicense=accept-securebackup-cookie;" "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" \
        && EXPECTED_CHECKSUM_MD5=`cat /tmp/checksum.html | grep -e "[\>\ ]${TGZ_FILE_NAME}" |sed s/".*md5:\ \([0-9a-fA-Z]*\).*"/"\1"/` \
        && EXPECTED_CHECKSUM_SHA256=`cat /tmp/checksum.html | grep -e "[\>\ ]${TGZ_FILE_NAME}" |sed s/".*sha256:\ \([0-9a-fA-Z]*\).*"/"\1"/` \
    ; fi \
    && CHECKSUM_MD5=`md5sum "/tmp/${TGZ_FILE_NAME}" | sed s/"^\([0-9a-fA-F]*\)\w\?.*$"/"\1"/` \
    && CHECKSUM_SHA256=`sha256sum "/tmp/${TGZ_FILE_NAME}" | sed s/"^\([0-9a-fA-F]*\)\w\?.*$"/"\1"/` \
    && wget -O "/tmp/checksum.html" "https://www.oracle.com/webfolder/s/digest/${JAVA_VERSION}u${JAVA_UPDATE}checksum.html" \
    && if [ "${EXPECTED_CHECKSUM_MD5}" != "${CHECKSUM_MD5}" -a "x${EXPECTED_CHECKSUM_MD5}" != "x" ]; then set; "Invalid MD5 checksum"; exit 1; else echo "MD5 checksum is valid"; fi \
    && if [ "${EXPECTED_CHECKSUM_SHA256}" != "${CHECKSUM_SHA256}" -a "x${EXPECTED_CHECKSUM_SHA256}" != "x" ]; then set; echo "Invalid SHA-256 checksum"; exit 2; else echo "SHA-256 checksum is valid"; fi \
    && rm "/tmp/checksum.html" \
    && apk del build-dependencies

RUN set -e \
    && apk add --no-cache --virtual=build-dependencies unzip \
    && mkdir -p "/usr/lib/jvm" \
    && tar xzf "/tmp/${TGZ_FILE_NAME}" -C "/usr/lib/jvm/" \
    && chown -R root:root "/usr/lib/jvm" \
    && ln -s `ls -ad /usr/lib/jvm/* | grep '_' | sed s/"\/usr\/lib\/jvm\/"//` /usr/lib/jvm/default \
    && if [ "x7" == "x${JAVA_VERSION}" ]; then \
        unzip -d "/tmp" "/tmp/jce-policy.zip" \
        && mv -f "/tmp/UnlimitedJCEPolicy/"*.jar "${JAVA_HOME}/jre/lib/security" \
        && rm -f "/tmp/jce-policy.zip" \
        && rm -rf "/tmp/UnlimitedJCEPolicy" \
    ; fi \
    && if [ "x8" == "x${JAVA_VERSION}" ]; then \
        unzip -d "/tmp" "/tmp/jce-policy.zip" \
        && mv -f "/tmp/UnlimitedJCEPolicyJDK8/"*.jar "${JAVA_HOME}/jre/lib/security" \
        && rm -f "/tmp/jce-policy.zip" \
        && rm -rf "/tmp/UnlimitedJCEPolicyJDK8" \
    ; fi \
    && ln -s "${JAVA_HOME}/bin/"* "/usr/bin/" \
    && rm -rf "${JAVA_HOME}/"*src.zip \
    && apk del build-dependencies \
    && rm "/tmp/${TGZ_FILE_NAME}"
    
RUN mkdir -p "/usr/lib/jvm/collectd"

ADD "artifacts/jcollectd.jar" "/usr/lib/jvm/collectd"
ADD "artifacts/jcollectd-conf.tar.gz" "/usr/lib/jvm/collectd"
