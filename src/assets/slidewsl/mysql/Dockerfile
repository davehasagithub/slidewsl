FROM percona:ps-5.7.44 as base

USER root

WORKDIR /var/lib/mysql

FROM base as development

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh mysql mysql \
    && printf "user: %s\ngroup: %s\npaths:\n  - /\n  - /var/lib/mysql/\n" mysql mysql > /etc/fixuid/config.yml

ENV PATH="$PATH:/usr/local/bin/mysql-scripts/"

ENTRYPOINT ["fixuid", "fix-perms.sh", "/docker-entrypoint.sh"]
CMD ["mysqld"]

FROM base as deployable

USER mysql

ARG CONF=${CONF:-undefined}
RUN if [ "${CONF}" = "undefined" ]; then echo "CONF is not set"; exit 1; fi
COPY --chmod=0444 ${CONF} /etc/my.cnf
