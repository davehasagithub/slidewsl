FROM oraclelinux:8 as os

ARG USER

RUN echo 'hosts: files dns' > /etc/nsswitch.conf \
    && ulimit -n 1024

RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

RUN --mount=type=cache,target=/var/cache/dnf \
    dnf makecache \
    && dnf -y update \
    && dnf install --noplugins -y \
      dnf-utils zip unzip git bash-completion telnet which hostname rsync dos2unix unix2dos sudo \
      docker-ce-cli

COPY --chmod=644 context/motd.sh /etc/profile.d
COPY --chmod=644 context/motd /etc
COPY --chmod=644 context/motd.extras* /etc
COPY context/docker-config.json /tmp
COPY --from=shared add-fixuid.sh /usr/local/bin
COPY --from=shared add-daveml.sh /usr/local/bin
COPY --chmod=644 context/dc-aliases.sh /etc/profile.d

RUN useradd ${USER} --create-home \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER} \
    && HOME1=$(getent passwd ${USER} | cut -d: -f6) \
    && echo 'cd ~'>>${HOME1}/.bashrc \
    && mkdir -p ${HOME1}/.docker \
    && mv /tmp/docker-config.json ${HOME1}/.docker/config.json \
    && chown -R ${USER}.${USER} ${HOME1}/.docker

RUN add-fixuid.sh ${USER} ${USER}
RUN add-daveml.sh

USER ${USER}

ENTRYPOINT ["fixuid"]
CMD sleep infinity
