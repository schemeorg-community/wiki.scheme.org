FROM debian:bullseye-slim AS build
RUN apt-get update && apt-get -y --no-install-recommends install \
      gcc make autoconf automake libtool m4 gettext pkg-config \
      git ca-certificates \
      netbase libgdbm-dev libgdbm-compat-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

## Gauche

WORKDIR /build
ADD https://github.com/shirok/Gauche/releases/download/release0_9_11/Gauche-0.9.11.tgz gauche.tgz
RUN mkdir gauche && tar -C gauche --strip-components 1 -xf gauche.tgz
WORKDIR /build/gauche
RUN ./configure --without-tls --with-dbm=ndbm
RUN make
RUN make install

## Makiki

WORKDIR /build
RUN git clone https://github.com/shirok/Gauche-makiki.git makiki
WORKDIR /build/makiki
RUN ./configure
RUN make
RUN make install

## Wiliki

#WORKDIR /build
#RUN git clone https://github.com/schemeorg/wiliki.git -b lassik wiliki
#WORKDIR /build/wiliki
##RUN ./configure
#RUN make
#RUN make install

## Run

FROM debian:bullseye-slim
RUN apt-get update && apt-get -y --no-install-recommends install \
      netbase libgdbm6 libgdbm-compat4 zlib1g \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/local/ /usr/local/
WORKDIR /
ADD https://misc.lassi.io/2021/community-scheme-wiki-2021-05-22.tar.gz csw.tgz
RUN tar -xf csw.tgz && rm csw.tgz && rm -rf csw/data
RUN mkdir -p /home/vhost/csw/data
RUN ln -s /home/vhost/csw/data /data
WORKDIR /csw
ADD wiki-http wiki-http
RUN chmod +x wiki-http
EXPOSE 80
CMD ["/csw/wiki-http"]
