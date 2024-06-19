ARG BUILD_IMAGE=undefined
FROM nginxinc/nginx-unprivileged:1.25.4 as base

USER root
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf

# https://github.com/nginxinc/docker-nginx-unprivileged/issues/88
ENV NGINX_ENVSUBST_OUTPUT_DIR=/tmp/nginx/conf.d
RUN mkdir -p /tmp/nginx/conf.d && chown -R nginx:nginx /tmp/nginx

FROM base as development

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh nginx nginx

RUN mkdir -p /etc/nginx/certs \
    && openssl genrsa -out /etc/nginx/certs/cert.key 2048 \
    && openssl req -new -key /etc/nginx/certs/cert.key -x509 -days 3650 -out /etc/nginx/certs/cert.crt -nodes -subj "/C=XX" \
    && chown -R nginx:nginx /etc/nginx/certs

USER nginx

ENTRYPOINT ["fixuid", "/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 4430 4200-4210

FROM ${BUILD_IMAGE} AS build-image

FROM base as deployable
ARG APP_NAME=${APP_NAME:-undefined}
COPY --from=build-image --chown=nginx:nginx /app/angular /app/angular/
COPY --from=build-image --chown=nginx:nginx /app/webroot /app/webroot/
COPY --chown=nginx:nginx templates /etc/nginx/templates
COPY --chown=nginx:nginx certs /etc/nginx/certs
USER nginx
WORKDIR /app/webroot
