FROM percona:ps-5.7.44 as base

USER root

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh mysql mysql \
    && printf "user: %s\ngroup: %s\npaths:\n  - /\n  - /var/lib/mysql/\n" mysql mysql > /etc/fixuid/config.yml

COPY fix-perms.sh /usr/local/bin

ENTRYPOINT ["fixuid", "fix-perms.sh", "/docker-entrypoint.sh"]
CMD ["mysqld"]

USER mysql
