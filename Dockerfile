FROM node:22

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-workspace.yaml .npmrc ./
COPY patches ./patches

RUN pnpm install

COPY . .

# Skip canvas A2UI bundle (vendor/apps excluded from Docker build context)
ENV OPENCLAW_A2UI_SKIP_MISSING=1
RUN pnpm build:docker
RUN pnpm ui:build || true

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

COPY openclaw.json /data/openclaw.json
CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured", "--port", "3000", "--bind", "lan"]
