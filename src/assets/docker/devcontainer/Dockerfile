# syntax=docker/dockerfile:1
FROM oraclelinux:8 as os

ARG USER
ARG UID
ARG GID
ENV DOCKER_HOST=tcp://127.0.0.1:2376
SHELL ["/bin/bash", "-c"]

RUN echo 'hosts: files dns' > /etc/nsswitch.conf \
    && ulimit -n 1024

RUN dnf -y update \
    && dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo \
    && dnf install --noplugins -y \
      dnf-utils zip unzip git bash-completion telnet which hostname rsync dos2unix unix2dos sudo \
      docker-ce-cli \
    && dnf clean all

COPY --chmod=644 context/motd.sh /etc/profile.d
COPY --chmod=644 context/motd /etc

RUN groupadd --gid ${GID} ${USER} \
    && useradd ${USER} --create-home --uid ${UID} --gid ${GID} \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER} \
    && HOME1=$(getent passwd ${USER} | cut -d: -f6) \
    && echo 'cd ~'>>${HOME1}/.bashrc

USER ${USER}

CMD sleep infinity
