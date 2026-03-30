FROM node:22

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-workspace.yaml .npmrc ./
COPY patches ./patches

RUN pnpm install

COPY . .

RUN pnpm build:docker || true
RUN pnpm ui:build || true

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
