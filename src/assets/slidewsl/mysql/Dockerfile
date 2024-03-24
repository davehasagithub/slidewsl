FROM percona:ps-5.7.44 as base

USER root

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh mysql mysql \
    && printf "user: %s\ngroup: %s\npaths:\n  - /\n  - /var/lib/mysql/\n" mysql mysql > /etc/fixuid/config.yml

ENV PATH="$PATH:/usr/local/bin/mysql-scripts/"

USER mysql

ENTRYPOINT ["fixuid", "fix-perms.sh", "/docker-entrypoint.sh"]
CMD ["mysqld"]
