ARG NODE_VERSION
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION}-bullseye as base

ARG NG_CLI_VERSION

ENV NG_CLI_ANALYTICS="false"

USER root

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh node node

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @angular/cli@${NG_CLI_VERSION}

ENV PATH="$PATH:/usr/local/bin/angular-scripts/"

USER node
ENTRYPOINT ["fixuid", "entrypoint.sh"]

FROM base as dev_server

ENTRYPOINT ["/bin/bash", "-c", "fixuid prepare-node-modules.sh run-dev-server.sh \"${APPS}\""]
EXPOSE 4300-4310
