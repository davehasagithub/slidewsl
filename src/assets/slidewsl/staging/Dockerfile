FROM alpine:3.17

RUN apk update && apk add --no-cache \
      bash \
      docker-cli \
      docker \
      openssh \
      supervisor \
      tzdata

RUN cp /usr/share/zoneinfo/America/New_York /etc/localtime && \
    echo "America/New_York" > /etc/timezone

COPY context/docker-daemon.json /etc/docker/daemon.json

COPY context/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir /var/run/sshd \
    && ssh-keygen -A \
    && echo 'root:password' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

COPY --chmod=644 context/motd /etc/
COPY --chmod=644 context/ps1.sh /etc/profile.d/

RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

EXPOSE 22

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
