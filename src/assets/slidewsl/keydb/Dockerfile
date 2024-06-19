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

RUN mkdir -p /data && chown keydb:keydb /data
WORKDIR /data

FROM base as development

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh keydb keydb \
    && printf "user: %s\ngroup: %s\npaths:\n  - /\n  - /data\n" keydb keydb > /etc/fixuid/config.yml

USER keydb

ENTRYPOINT ["fixuid", "cluster-meet.sh", "docker-entrypoint.sh"]
CMD ["keydb-server", "/etc/keydb/keydb.conf"]

FROM base as deployable

ARG CONF=${CONF:-undefined}
RUN if [ "${CONF}" = "undefined" ]; then echo "CONF is not set"; exit 1; fi
COPY ${CONF} /etc/keydb/
ENTRYPOINT ["cluster-meet.sh", "docker-entrypoint.sh"]
CMD ["keydb-server", "/etc/keydb/keydb.conf"]
