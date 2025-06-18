ARG RUBY_VERSION=3.4
ARG NODE_VERSION=20

FROM ruby:${RUBY_VERSION}

ARG NODE_VERSION

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update && apt-get install -y \
    git \
    nodejs \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
