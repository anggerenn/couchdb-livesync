# CouchDB for Obsidian LiveSync (Coolify)

Self-configuring CouchDB for use with the [Obsidian LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin. Deploy via Coolify — no manual curl commands needed.

## Deploy on Coolify

### 1. Create a new Resource
- In Coolify, click **+ New Resource** → **Docker Compose**
- Choose **"From a GitHub repository"** and connect this repo

### 2. Set Environment Variables
In the Coolify service settings, add these two variables:

| Variable | Value |
|---|---|
| `COUCHDB_USER` | your chosen username (e.g. `admin`) |
| `COUCHDB_PASSWORD` | a strong password |

### 3. Set a Domain
- In the service settings, assign a domain (e.g. `couchdb.yourdomain.com`)
- Coolify will handle HTTPS automatically

### 4. Deploy
Hit **Deploy**. The container will:
1. Start CouchDB
2. Automatically run all configuration (CORS, auth, size limits, etc.)

You can verify it worked by visiting `https://couchdb.yourdomain.com` — you should see a JSON response asking for credentials.

---

## Connect to Obsidian

Run this locally to generate your setup URI (one time only):

```bash
docker run \
  -e hostname=https://couchdb.yourdomain.com \
  -e database=obsidiannotes \
  -e username=YOUR_COUCHDB_USER \
  -e password=YOUR_COUCHDB_PASSWORD \
  -e passphrase=somesecretpassphrase \
  docker.io/oleduc/docker-obsidian-livesync-couchdb:master \
  deno -A /scripts/generate_setupuri.ts
```

Then in Obsidian:
1. Install the **Self-hosted LiveSync** plugin
2. Open command palette → **"Use the copied setup URI"**
3. Paste the URI and enter your passphrase
4. Follow the wizard

Save your `passphrase` — you'll need it each time you add a new device.