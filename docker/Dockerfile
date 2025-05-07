FROM  quay.io/sclorg/nodejs-20-c9s@sha256:fcf0b5ce281fe5e5755049dbb08e3912853e95f2f80327771a27b7459957b4f4 AS devel

ARG NPM_BUILD="pnpm install --frozen-lockfile"

USER root
RUN npm install -g pnpm

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN $NPM_BUILD
COPY ./ ./


FROM  quay.io/sclorg/nodejs-20-minimal-c9s@sha256:9bd8f92af40b0746eb3d8e86abf8d41e4bed8bfa48cbf84225e1a7d413d05d2a AS release

LABEL maintainer="TitaniumNetwork Ultraviolet Team"
LABEL summary="Ultraviolet Proxy Image"
LABEL description="Example application of Ultraviolet which can be deployed in production."

WORKDIR /app
COPY --from=devel /app/node_modules node_modules
COPY --from=devel /app/src/index.js src/index.js
COPY --from=devel /app/package.json package.json

ENTRYPOINT [ "/usr/bin/node" ]
CMD [ "src/index.js" ]