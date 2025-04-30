FROM  quay.io/sclorg/nodejs-20-c9s@sha256:ee2b30f2b90d5abad8b531522e2dd0269517c0c5bd354e11f4b27198a4acec8c AS devel

ARG NPM_BUILD="pnpm install --frozen-lockfile"

USER root
RUN npm install -g pnpm

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN $NPM_BUILD
COPY ./ ./


FROM  quay.io/sclorg/nodejs-20-minimal-c9s@sha256:5a1e2a2bf199aa7afcb7e41e6cb26a17072f0ccc3b545d0b71d4ff1780bd8fcb AS release

LABEL maintainer="TitaniumNetwork Ultraviolet Team"
LABEL summary="Ultraviolet Proxy Image"
LABEL description="Example application of Ultraviolet which can be deployed in production."

WORKDIR /app
COPY --from=devel /app/node_modules node_modules
COPY --from=devel /app/src/index.js src/index.js
COPY --from=devel /app/package.json package.json

ENTRYPOINT [ "/usr/bin/node" ]
CMD [ "src/index.js" ]