FROM lsiobase/python:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SICKGEAR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="xe, sparkyballs, homerr"

# set python to use utf-8 rather than ascii.
ENV PYTHONIOENCODING="UTF-8"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
        gcc \
        musl-dev \
        python-dev && \
 echo "install pip packages ****" && \
 pip install -U \
        regex \
        scandir && \
 echo "**** install app ****" && \
 mkdir -p \
        /app/sickgear/ && \
 if [ -z ${SICKGEAR_RELEASE+x} ]; then \
        SICKGEAR_RELEASE=$(curl -sX GET "https://api.github.com/repos/sickgear/sickgear/releases/latest" \
        | awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/sickgear.tar.gz -L \
        "https://github.com/sickgear/sickgear/archive/${SICKGEAR_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/sickgear.tar.gz -C \
        /app/sickgear/ --strip-components=1 && \
 echo "**** cleanup ****" && \
 apk del --purge \
        build-dependencies

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8081
VOLUME /config /downloads /tv
