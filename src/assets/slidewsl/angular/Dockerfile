ARG NODE_VERSION
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION}-bullseye as base

ARG NG_CLI_VERSION

ENV NG_CLI_ANALYTICS="false"

USER root

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \
      chromium \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh node node

COPY ./scripts/chromium.sh /usr/local/bin/chromium.sh
ENV CHROME_BIN="/usr/local/bin/chromium.sh"

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @angular/cli@${NG_CLI_VERSION}

ENV PATH="$PATH:/usr/local/bin/angular-scripts/"

WORKDIR /angular

USER node
ENTRYPOINT ["fixuid", "entrypoint.sh"]

FROM base as dev_server

ENTRYPOINT ["/bin/bash", "-c", "fixuid prepare-node-modules.sh run-dev-server.sh \"${APPS}\""]
EXPOSE 4300-4310
