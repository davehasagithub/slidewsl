FROM phpmyadmin:5.2.1-apache as base

RUN useradd phpmyadmin --create-home

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh phpmyadmin phpmyadmin \
    && chown -R phpmyadmin:phpmyadmin /etc/phpmyadmin/ \
    && printf "user: %s\ngroup: %s\npaths:\n  - /\n  - /etc/phpmyadmin/\n" phpmyadmin phpmyadmin > /etc/fixuid/config.yml

RUN ls -l /etc/phpmyadmin

COPY fix-perms.sh /usr/local/bin

ENTRYPOINT ["fixuid", "fix-perms.sh", "/docker-entrypoint.sh"]
CMD ["apache2-foreground"]

USER phpmyadmin
