FROM quay.io/almalinuxorg/9-base AS installer

RUN dnf module --assumeyes enable nodejs:18
RUN dnf install --assumeyes --setopt=install_weak_deps=false --nodocs \
  git jq npm wget

RUN npm install -g npm@$(curl "https://release-monitoring.org/api/v2/versions/?project_id=190206" | jq --raw-output '.stable_versions[0]')
RUN npm install -g yarn

FROM installer AS builder

RUN git clone --depth=1 --recursive https://github.com/titaniumnetwork-dev/Ultraviolet.git Ultraviolet
RUN git clone --depth=1 --recursive https://github.com/titaniumnetwork-dev/Ultraviolet-Static.git Ultraviolet-Static

WORKDIR /tmp
COPY package.json ./
# RUN npm install --omit=dev --frozen-lockfile
# RUN npm update
RUN yarn install --production

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY ./ ./
RUN cp -r /tmp/node_modules ./src/node_modules



FROM quay.io/almalinuxorg/9-base AS base

RUN mkdir /rpms
RUN dnf module --assumeyes --installroot /rpms --releasever=9 enable nodejs:18

COPY --from=quay.io/almalinuxorg/9-micro / /rpms
RUN dnf install --assumeyes --setopt=install_weak_deps=false --nodocs \
  --installroot /rpms \
  --releasever=9 \
  nodejs ca-certificates

RUN dnf clean all \
  --installroot /rpms


FROM base AS release

COPY --from=base /rpms /
# COPY --from=builder /tmp/node_modules /app/node_modules
COPY --from=builder /usr/src/app /app
WORKDIR /app

#EXPOSE 8080/tcp
ENTRYPOINT ["node", "src/index.js"]
