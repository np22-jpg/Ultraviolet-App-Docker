FROM quay.io/almalinuxorg/9-base AS installer

RUN dnf module --assumeyes enable nodejs
RUN dnf install --assumeyes --setopt=install_weak_deps=false --nodocs \
  git jq npm wget

RUN npm install -g npm@$(curl "https://release-monitoring.org/api/v2/versions/?project_id=190206" | jq --raw-output '.stable_versions[0]')

# FROM installer AS gitprovider

# ARG REPO
# RUN mkdir -p /usr/src/app
# RUN git clone https://github.com/$REPO.git /usr/src/app
# RUN cp /usr/src/app/package.json /tmp/package.json
# WORKDIR /tmp
# RUN npm install

# FROM installer AS relprovider

# ARG REPO
# RUN wget -q -O- "$(curl https://api.github.com/repos/$REPO/releases/latest | jq -r ".tarball_url")" |  tar -xz -C /Ultraviolet-App
# WORKDIR /Ultraviolet-App
# RUN npm install

FROM installer AS builder
WORKDIR /tmp
COPY package.json ./
RUN npm install --omit=dev --frozen-lockfile

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY ./ ./
RUN cp -r /tmp/node_modules ./src/node_modules


FROM installer AS base

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
