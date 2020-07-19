#
# Development
#

FROM elixir:1.10 as development

ENV APP_HOME /usr/src/app
ENV LANG C.UTF-8

EXPOSE 4000

WORKDIR $APP_HOME

# install supporting tools
RUN mix local.hex --force
RUN mix local.rebar --force

# copy dependencies
COPY ./server/mix.exs ./server/mix.lock ./server/.formatter.exs ./
COPY ./server/config config

RUN MIX_ENV=dev mix do deps.get, deps.compile
RUN MIX_ENV=test mix do deps.get deps.compile

# copy in the applications
COPY ./server/lib lib

# create a release
#RUN MIX_ENV=prod mix release gotchas

#CMD mix phx.server

#
# Deploy
#
FROM debian:buster-slim as deploy

ENV APP_HOME /usr/src/app
ENV LANG C.UTF-8

EXPOSE 4000

WORKDIR $APP_HOME

# Install libs
RUN apt-get update && \
    apt-get install -yq \
    libssl-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY --from=development $APP_HOME/_build/prod/rel/gotchas $APP_HOME

CMD bin/gotchas start
