FROM phpmyadmin:5.2.1-apache as base

RUN useradd phpmyadmin --create-home

RUN chown -R phpmyadmin:phpmyadmin /etc/phpmyadmin/

FROM base as development

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh phpmyadmin phpmyadmin \
    && printf "user: %s\ngroup: %s\npaths:\n  - /\n  - /etc/phpmyadmin/\n" phpmyadmin phpmyadmin > /etc/fixuid/config.yml

COPY fix-perms.sh /usr/local/bin

ENTRYPOINT ["fixuid", "fix-perms.sh", "/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
USER phpmyadmin
EXPOSE 8080

FROM base as deployable

USER phpmyadmin

ARG CONF=${CONF:-undefined}
RUN if [ "${CONF}" = "undefined" ]; then echo "CONF is not set"; exit 1; fi
COPY --chmod=0444 ${CONF} /etc/phpmyadmin/conf.d
EXPOSE 8080
