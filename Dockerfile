FROM node:20-bookworm-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl git openssl procps && \
            rm -rf /var/lib/apt/lists/*

            # Install pnpm
            RUN npm install -g pnpm

            # Copy package files first for better layer caching
            COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./

            # Copy UI package.json if it exists
            COPY ui/package.json ./ui/package.json

            # Copy patches directory
            COPY patches ./patches

            # Install dependencies
            RUN pnpm install --frozen-lockfile

            # Copy the rest of the source code
            COPY . .

            # Build the project
            RUN pnpm build:docker || true
            RUN pnpm ui:build || true

            ENV NODE_ENV=production
            ENV PORT=3000

            EXPOSE 3000

            CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
