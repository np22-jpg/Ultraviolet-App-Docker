FROM  quay.io/sclorg/nodejs-20-c9s@sha256:aba7437faf029282f93a169f868dd684f0ecf9ca20004a12820637ec2c6f2280 AS devel

ARG NPM_BUILD="pnpm install --frozen-lockfile"

USER root
RUN npm install -g pnpm

WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN $NPM_BUILD
COPY ./ ./


FROM  quay.io/sclorg/nodejs-20-minimal-c9s@sha256:3b5cc352e2e6c3ceddee2281f78a41c5054869e302b5b546c27a7f78eeb0aea4 AS release

LABEL maintainer="TitaniumNetwork Ultraviolet Team"
LABEL summary="Ultraviolet Proxy Image"
LABEL description="Example application of Ultraviolet which can be deployed in production."

WORKDIR /app
COPY --from=devel /app/node_modules node_modules
COPY --from=devel /app/src/index.js src/index.js
COPY --from=devel /app/package.json package.json

ENTRYPOINT [ "/usr/bin/node" ]
CMD [ "src/index.js" ]