FROM node:20

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY patches ./patches

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm build:docker || true
RUN pnpm ui:build || true

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
