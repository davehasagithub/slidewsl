ARG BUILD_IMAGE=undefined
ARG NODE_VERSION
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION}-bullseye as base

USER root
ARG NG_CLI_VERSION
ENV NG_CLI_ANALYTICS="false"

RUN --mount=type=cache,target=/root/.npm \
    npm install -g @angular/cli@${NG_CLI_VERSION}

RUN mkdir -p /home/node/.cache/yarn \
    && chown -R node:node /home/node/.cache/yarn

FROM base as development-base

COPY --from=shared add-fixuid.sh /usr/local/bin
RUN add-fixuid.sh node node

ENV PATH="$PATH:/usr/local/bin/angular-scripts/"

FROM development-base as development

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \
      chromium \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./scripts/chromium.sh /usr/local/bin/chromium.sh

ENV CHROME_BIN="/usr/local/bin/chromium.sh"

ENTRYPOINT ["fixuid", "entrypoint.sh"]

FROM development-base as dev_server

ENTRYPOINT ["/bin/bash", "-c", "fixuid prepare-node-modules.sh run-dev-server.sh \"${APPS}\""]
EXPOSE 4300-4310

FROM development-base AS dev-angular-ssr
WORKDIR /app
USER node
ENTRYPOINT ["/bin/bash", "-c", "fixuid node /app/angular/dist/\"${APP}\"/server/server.mjs /app/angular/dist/\"${APP}\"/server"]

FROM base as build

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \
      iputils-ping telnet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/angular /app/laravel /app/webroot && chown -R node:node /app
ARG APP_NAME=${APP_NAME:-undefined}
ARG BASE_HREF=/
COPY --from=angular --chown=node:node package.json yarn.lock /app/angular/
RUN yarn install --frozen-lockfile
COPY --from=angular --chown=node:node . /app/angular/
RUN echo appname $APP_NAME
RUN if [ "${APP_NAME}" = "undefined" ]; then echo "APP_NAME is not set"; exit 1; fi
RUN ng build "${APP_NAME}" --base-href="${BASE_HREF}" --configuration=development
COPY --from=laravel --chown=node:node . /app/laravel/
COPY --from=webroot --chown=node:node . /app/webroot/
WORKDIR /app

FROM ${BUILD_IMAGE} AS build-image

FROM base AS angular-ssr
ARG APP_NAME=${APP_NAME:-undefined}
COPY --from=build-image --chown=node:node /app/angular/dist/${APP_NAME} /app
WORKDIR /app
USER node
CMD ["node", "server/server.mjs", "."]
