# build app
FROM docker.io/node AS builder

RUN apt update
RUN apt install git

RUN mkdir -p /usr/share/src/
COPY package.json .
RUN npm install --omit=dev --frozen-lockfile
COPY src .

# build final
FROM gcr.io/distroless/nodejs:18 AS release-aio

# EXPOSE 8080/tcp

RUN mkdir /app
WORKDIR /app
COPY --from=builder /usr/share/src .
RUN chmod +x entrypoint.sh

COPY nginx.conf.example /etc/nginx/conf.d/uv.conf


ENTRYPOINT ["/usr/bin/bash", "-c", "entrypoint.sh"]
CMD ["node", "index.js"]