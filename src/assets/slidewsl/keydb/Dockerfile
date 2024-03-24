FROM eqalpha/keydb:x86_64_v6.3.4 as base

USER root

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \
      curl \
      ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY cluster-meet.sh /usr/local/bin

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh keydb keydb \
    && chown keydb:keydb /data \
    && printf "user: %s\ngroup: %s\npaths:\n  - /\n  - /data\n" keydb keydb > /etc/fixuid/config.yml

ENTRYPOINT ["fixuid", "cluster-meet.sh", "docker-entrypoint.sh"]
CMD ["keydb-server", "/etc/keydb/keydb.conf"]

USER keydb
