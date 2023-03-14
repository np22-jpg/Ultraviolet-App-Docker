FROM quay.io/fedora/fedora AS devel
ARG NPM_BUILD=i

RUN --mount=type=cache,target=/var/cache/dnf \
    dnf install --nodocs -y --setopt install_weak_deps=false npm nodejs

RUN mkdir /app
WORKDIR /app

COPY package.json package-lock.json ./
RUN /usr/bin/npm $NPM_BUILD
COPY . .

# Loosely based on https://catalog.redhat.com/software/containers/ubi9/ubi-micro/615bdf943f6014fa45ae1b58?container-tabs=dockerfile
FROM devel AS image-builder
RUN mkdir -p /output_container
RUN --mount=type=cache,target=/var/cache/dnf \
    source /etc/os-release && \
    dnf install --releasever $VERSION_ID --nodocs -y \
    --installroot /output_container --setopt install_weak_deps=false \
    --setopt=cachedir=/var/cache/dnf \
    coreutils-single glibc-minimal-langpack nodejs curl-minimal && \
    dnf --installroot /output_container clean all

FROM scratch AS release

LABEL maintainer="TitaniumNetwork Ultraviolet Team"
LABEL summary="Ultraviolet Proxy Image"
LABEL description="Example application of Ultraviolet which can be deployed in production."

# Grab packages 
COPY --from=image-builder /output_container/ / 
# Grab Ultraviolet
RUN echo "node::1000:1000::/app:/bin/sh" >> /etc/passwd 
USER node
COPY --from=devel --chown=1000:1000 /app /app
WORKDIR /app
RUN rm -rf $(cat docker/REMOVE_FROM_FINAL)

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s \
  CMD /usr/bin/curl -f http://localhost:8080 || false

ENTRYPOINT [ "/usr/bin/node" ]
CMD [ "src/index.js" ]