FROM --platform=$BUILDPLATFORM node:14.20.1-bullseye as node_base

ENV NG_CLI_ANALYTICS="false"
ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @angular/cli@15.2.8

COPY --from=shared --chown=node add-fixuid.sh /home/node
RUN chmod u+x /home/node/add-fixuid.sh
RUN /home/node/add-fixuid.sh node node

COPY --chown=node angular-folder-fixup.sh /home/node
RUN chmod u+x /home/node/angular-folder-fixup.sh

USER node
ENTRYPOINT ["fixuid", "/home/node/angular-folder-fixup.sh"]

FROM node_base as app_build

COPY --chown=node angular-build.sh /home/node
RUN chmod u+x /home/node/angular-build.sh
ENTRYPOINT ["fixuid", "/home/node/angular-folder-fixup.sh", "/home/node/angular-build.sh"]

FROM node_base as dev_server

COPY --chown=node angular-dev-server.sh angular-dev-server.conf.sh /home/node/
RUN chmod u+x /home/node/angular-dev-server.sh
ENTRYPOINT ["/bin/bash", "-c", "fixuid /home/node/angular-folder-fixup.sh /home/node/angular-dev-server.sh \"${APPS:-err}\""]
EXPOSE 4200-4210
