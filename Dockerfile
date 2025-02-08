FROM ruby:3.4-alpine

ENV LANG=C.UTF-8 \
    APP_HOME=/gemsrc

# `japanese_address_parser.gemspec` needs git.
RUN apk update && \
    apk add --virtual build-dependencies --no-cache git nodejs make gcc musl-dev

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY . $APP_HOME

RUN bundle install

CMD sh -c "/bin/sh"
