FROM oven/bun:alpine AS build
WORKDIR /usr/src/app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

FROM alpine AS release
WORKDIR /usr/src/app

RUN adduser -D -u 1000 appuser
COPY --from=build --chown=appuser:appuser /usr/src/app/dist/index ./index

USER appuser
EXPOSE 3000/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/ || exit 1

ENTRYPOINT ["./index"]
