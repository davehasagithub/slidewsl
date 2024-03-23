FROM --platform=$BUILDPLATFORM node:14.20.1-bullseye as base

ENV NG_CLI_ANALYTICS="false"

USER root

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh node node

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @angular/cli@15.2.8

ENV PATH="$PATH:/usr/local/bin/angular-scripts/"

USER node
ENTRYPOINT ["fixuid", "entrypoint.sh"]

FROM base as dev_server

ENTRYPOINT ["/bin/bash", "-c", "fixuid prepare-node-modules.sh run-dev-server.sh \"${APPS}\""]
EXPOSE 4300-4310
