FROM oven/bun:alpine AS build
WORKDIR /usr/src/app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .
RUN bun run build

FROM oven/bun:alpine AS release
WORKDIR /usr/src/app

RUN apk add --no-cache curl

COPY --from=build /usr/src/app/dist/index ./dist/index

USER bun
EXPOSE 3000/tcp
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1:3000/ || exit 1

ENTRYPOINT ["./dist/index"]
