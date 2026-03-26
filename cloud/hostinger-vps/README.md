# Hostinger VPS Deployment Bundle

This folder is the organized cloud handoff for running OpenClaw on a Hostinger VPS without depending on your laptop.

## What is in here

- `docker-compose.yml`: Hostinger-ready Docker Compose stack for the Gateway and CLI
- `.env.example`: one place for your static credentials and deployment secrets
- `openclaw.json.example`: minimal runtime config template
- `systemd/openclaw-compose.service`: optional boot-time service wrapper for Docker Compose
- `create-transfer-bundle.sh`: packages this repo for upload to the VPS

## Recommended VPS layout

Use this structure on the server:

```text
/opt/openclaw/
  data/
    state/
    workspace/
  openclaw/
    cloud/hostinger-vps/
    Dockerfile
    docker-compose.yml
    src/
    ...
```

The persistent data lives outside the repo:

- `state`: OpenClaw config, auth, sessions, credentials
- `workspace`: agent workspaces and files

Keep this split:

- `.env`: static secrets you paste and rotate manually
- `state`: OpenClaw-managed runtime state like sessions, channel state, pairing, and generated credentials

Do not try to flatten the entire runtime into `.env`. OpenClaw expects session and channel state to remain in the state directory.

## Local prep

From the repo root:

```bash
chmod +x cloud/hostinger-vps/create-transfer-bundle.sh
./cloud/hostinger-vps/create-transfer-bundle.sh
```

That creates a tarball one directory above the repo by default.

## Upload to the VPS

Example:

```bash
scp ../openclaw-hostinger-bundle.tgz root@YOUR_VPS_IP:/opt/openclaw/
ssh root@YOUR_VPS_IP
cd /opt/openclaw
tar -xzf openclaw-hostinger-bundle.tgz
mv openclaw-2026.3.13-1 openclaw
```

If the extracted folder name differs, rename it to `openclaw`.

## VPS bootstrap

Install Docker:

```bash
apt-get update
apt-get install -y git curl ca-certificates
curl -fsSL https://get.docker.com | sh
docker --version
docker compose version
```

Create persistent directories:

```bash
mkdir -p /opt/openclaw/data/state /opt/openclaw/data/workspace
chown -R 1000:1000 /opt/openclaw/data
```

## Configure OpenClaw

```bash
cd /opt/openclaw/openclaw/cloud/hostinger-vps
cp .env.example .env
cp openclaw.json.example /opt/openclaw/data/state/openclaw.json
```

Edit `.env` and replace:

- `OPENCLAW_GATEWAY_TOKEN`
- timezone
- any provider credentials you actually use

Recommended rule:

- Put API keys, bot tokens, SMTP passwords, and similar stable secrets in `.env`
- Keep OpenClaw chat/session/channel history in `/opt/openclaw/data/state`

Generate a token:

```bash
openssl rand -hex 32
```

## Start the stack

```bash
cd /opt/openclaw/openclaw/cloud/hostinger-vps
docker compose up -d --build
docker compose ps
docker compose logs -f openclaw-gateway
```

## Connect

The compose file binds OpenClaw to VPS loopback only.
Use an SSH tunnel from your machine:

```bash
ssh -N -L 18789:127.0.0.1:18789 root@YOUR_VPS_IP
```

Then open:

```text
http://127.0.0.1:18789/
```

Use the token from `.env`.

## Optional boot persistence

Install the systemd unit:

```bash
cp systemd/openclaw-compose.service /etc/systemd/system/openclaw-compose.service
systemctl daemon-reload
systemctl enable --now openclaw-compose.service
systemctl status openclaw-compose.service
```

## Day-to-day commands

```bash
cd /opt/openclaw/openclaw/cloud/hostinger-vps
docker compose up -d --build
docker compose pull
docker compose logs -f openclaw-gateway
docker compose run --rm openclaw-cli dashboard --no-open
docker compose run --rm openclaw-cli devices list
docker compose run --rm openclaw-cli config set gateway.bind loopback
```

## Notes

- This is set up for a VPS-first deployment, not a laptop host.
- Keep the gateway on `loopback` unless you deliberately add another secure access layer.
- Do not store persistent OpenClaw state inside the repo tree on the server.
- `.env` is for static credentials only; session history, Telegram pairing state, and OpenClaw chat state remain in the state directory.
