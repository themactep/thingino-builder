# syntax=docker/dockerfile:1

FROM debian:testing

RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update && \
DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
ack apt-utils apt-transport-https bc bison build-essential busybox \
ca-certificates ccache cmake cpio curl dialog file flex \
gawk gcc-mipsel-linux-gnu git golang-go libncurses-dev \
locales lzop mc nano python3 python3-jinja2 python3-jsonschema \
rsync ssh sudo toilet u-boot-tools unzip vim wget whiptail

#fknano
RUN update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1 && \
update-alternatives --set editor /usr/bin/vim && \
update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1 && \
update-alternatives --set vi /usr/bin/vim

RUN update-ca-certificates

RUN locale-gen --no-purge en_US.UTF-8

RUN useradd -rm -d /home/me -s /bin/bash -g root -G sudo -u 1000 me --no-log-init
RUN echo 'me:me' | chpasswd

USER me

ENV BR2_DL_DIR=/home/me/downloads

WORKDIR /home/me/thingino

RUN git config --global --add safe.directory /home/me/thingino
RUN git config --global alias.up 'pull --rebase --autostash'
