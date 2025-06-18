# Dev Container Configuration

This directory contains the development container configuration for the Japanese Address Parser project.

## Version Management

Ruby and Node.js versions can be configured by copying `.env.example` to `.env` and modifying the values:

```bash
cd .devcontainer
cp .env.example .env
```

Edit `.env` to set your desired versions:

```bash
# Ruby version
RUBY_VERSION=3.4

# Node.js version (major version)
NODE_VERSION=20
```

The `.env` file is automatically created from `.env.example` when opening the project in VS Code if it doesn't exist.

## Supported Versions

- Ruby: Any version available on [Docker Hub ruby images](https://hub.docker.com/_/ruby)
- Node.js: Major versions supported by [NodeSource](https://github.com/nodesource/distributions) (e.g., 18, 20, 22)
