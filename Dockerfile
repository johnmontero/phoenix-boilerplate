FROM jmontero/phoenix:1.5.1

COPY ./src /app/src

WORKDIR /app/src
RUN mix deps.get && mix deps.compile

# Needed for each app with assets
WORKDIR /app/src/apps/frontend/assets
RUN npm install \
      && npx webpack --mode production
#################################

WORKDIR /app/src/
RUN mix phx.digest \
      && MIX_ENV=prod mix release --env=prod

FROM alpine:3.11

RUN apk --no-cache add -U musl musl-dev ncurses-libs libressl2.7-libcrypto bash

COPY --from=0 /app/src/_build/prod/rel /rel

WORKDIR /rel
CMD /rel/phx/bin/phx foreground
