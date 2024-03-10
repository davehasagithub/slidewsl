FROM --platform=$BUILDPLATFORM node:14.20.1-bullseye as node_base

ENV NG_CLI_ANALYTICS="false"

USER root

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh node node

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @angular/cli@15.2.8

COPY scripts/prepare-node-modules.sh /usr/local/bin

USER node
ENTRYPOINT ["fixuid", "prepare-node-modules.sh"]

FROM node_base as starter

COPY scripts/create-starter-app.sh /usr/local/bin
ENTRYPOINT ["fixuid", "create-starter-app.sh"]

FROM node_base as app_build

COPY scripts/build.sh /usr/local/bin
ENTRYPOINT ["fixuid", "prepare-node-modules.sh", "build.sh"]

FROM node_base as dev_server

COPY scripts/run-dev-server.sh /usr/local/bin/
COPY dev-server.conf /usr/local/etc/
ENTRYPOINT ["/bin/bash", "-c", "fixuid prepare-node-modules.sh run-dev-server.sh \"${APPS:-err}\""]
EXPOSE 4200-4210
