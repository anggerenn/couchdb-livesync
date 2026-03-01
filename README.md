# CouchDB for Obsidian LiveSync (Coolify)

Self-configuring CouchDB for use with the [Obsidian Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin. Deploy via Coolify — no manual curl commands needed. Supports multiple users/vaults on a single instance.

---

## Repo Structure

```
obsidian-livesync-couchdb/
├── Dockerfile          # Builds from official couchdb:3, bakes config in
├── docker-compose.yml  # Coolify deployment config
├── local.ini           # All CouchDB config (CORS, auth, limits, etc.)
└── README.md
```

---

## Deploy on Coolify

### 1. Create a new Resource
- In Coolify, click **+ New Resource** → **Docker Compose**
- Choose **"From a GitHub repository"** and connect this repo

### 2. Set Environment Variables
In the Coolify service settings, add:

| Variable | Value |
|---|---|
| `COUCHDB_USER` | your chosen username (e.g. `admin`) |
| `COUCHDB_PASSWORD` | a strong password |

### 3. Set a Domain
- Assign a domain (e.g. `couchdb.yourdomain.com`)
- In the domain field in Coolify, set it as `https://couchdb.yourdomain.com:5984` — the `:5984` tells Traefik to proxy to CouchDB's internal port
- The public URL you actually use will be just `https://couchdb.yourdomain.com` (no port)
- Coolify handles HTTPS automatically

### 4. Deploy
Hit **Deploy**. Verify it's working:
```bash
curl -u YOUR_COUCHDB_USER:YOUR_COUCHDB_PASSWORD https://couchdb.yourdomain.com
# Should return: {"couchdb":"Welcome","version":"3.5.1"...}
```

---

## Connect to Obsidian

### Step 1: Generate Setup URI (once per vault)
Run this locally for each family member / vault:

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

Save the `passphrase` — you'll need it every time you add a new device.

### Step 2: Configure Obsidian
1. Install **Self-hosted LiveSync** plugin (Community Plugins)
2. Open command palette (`Cmd/Ctrl + P`) → **"Use the copied setup URI"**
3. Paste the URI and enter your passphrase
4. Follow the wizard:
   - **Fetch Remote Configuration Failed** → click **"Skip and proceed"** (expected on first setup)
   - **Send all chunks before replication?** → **Yes**
   - **Overwrite server** confirmation → check all boxes → proceed
   - **Send all chunks before replication?** → **Yes** again

### Step 3: Enable LiveSync mode (near real-time sync)
After setup, go to **LiveSync plugin settings** → **Sync Settings** → change **Sync Mode** from `On events` to **`LiveSync`**. This keeps a continuous connection to CouchDB for near-instant syncing across all devices.

---

## Multiple Users / Family

Each person gets their own isolated database. Run the URI generator with a different `database` name per person:

```bash
# Person 1
-e database=vault-john

# Person 2  
-e database=vault-jane
```

For each additional **device** of the same person, reuse the same URI and passphrase — no need to regenerate.

---

## Notes
- Data is persisted in the `couchdb-data` Docker volume — redeploying won't wipe it
- Obsidian vaults are small (usually under 100MB) so storage is rarely a concern
- Port 5984 is internal only — Traefik proxies public HTTPS traffic to it, never expose it publicly