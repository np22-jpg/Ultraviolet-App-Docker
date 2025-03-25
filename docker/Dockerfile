FROM  quay.io/sclorg/nodejs-20-c9s@sha256:d2629c2fd7a9fb727dda696a93130f3f3ec8f3cdd50e313db61c039be150c029 AS devel

ARG NPM_BUILD="pnpm install --frozen-lockfile"

USER root
RUN npm install -g pnpm

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN $NPM_BUILD
COPY ./ ./


FROM  quay.io/sclorg/nodejs-20-minimal-c9s@sha256:2c6fb7c3cc36cbefe397f5cbb27c118284c7fb59d5d785c8874651b07c9906e4 AS release

LABEL maintainer="TitaniumNetwork Ultraviolet Team"
LABEL summary="Ultraviolet Proxy Image"
LABEL description="Example application of Ultraviolet which can be deployed in production."

WORKDIR /app
COPY --from=devel /app/node_modules node_modules
COPY --from=devel /app/src/index.js src/index.js
COPY --from=devel /app/package.json package.json

ENTRYPOINT [ "/usr/bin/node" ]
CMD [ "src/index.js" ]