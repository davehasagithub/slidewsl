FROM nginxinc/nginx-unprivileged:1.25.4 as base

USER root

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh nginx nginx

USER nginx
# https://github.com/nginxinc/docker-nginx-unprivileged/issues/88
ENV NGINX_ENVSUBST_OUTPUT_DIR=/tmp/nginx/conf.d
RUN mkdir -p /tmp/nginx/conf.d

USER root

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/certs \
    && openssl genrsa -out /etc/nginx/certs/cert.key 2048 \
    && openssl req -new -key /etc/nginx/certs/cert.key -x509 -days 3650 -out /etc/nginx/certs/cert.crt -nodes -subj "/C=XX" \
    && chown -R nginx:nginx /etc/nginx/certs

WORKDIR /webroot

ENTRYPOINT ["fixuid", "/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

USER nginx
EXPOSE 8080
