#!/bin/bash

# Wait until CouchDB is actually up and responding
echo "[init] Waiting for CouchDB to start..."
until curl -sf http://localhost:5984/ > /dev/null 2>&1; do
  sleep 2
done
echo "[init] CouchDB is up. Running configuration..."

NODE="couchdb@127.0.0.1"
LOCAL="http://localhost:5984"
AUTH="${COUCHDB_USER}:${COUCHDB_PASSWORD}"

# Step 1: Enable single node mode
curl -sf -X POST "${LOCAL}/_cluster_setup" \
  -H "Content-Type: application/json" \
  -d "{\"action\":\"enable_single_node\",\"username\":\"${COUCHDB_USER}\",\"password\":\"${COUCHDB_PASSWORD}\",\"bind_address\":\"0.0.0.0\",\"port\":5984,\"singlenode\":true}" \
  --user "${AUTH}"

# Step 2: Require valid user for all requests (security)
curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/chttpd/require_valid_user" \
  -H "Content-Type: application/json" -d '"true"' --user "${AUTH}"

curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/chttpd_auth/require_valid_user" \
  -H "Content-Type: application/json" -d '"true"' --user "${AUTH}"

# Step 3: Set auth header
curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/httpd/WWW-Authenticate" \
  -H "Content-Type: application/json" -d '"Basic realm=\"couchdb\""' --user "${AUTH}"

# Step 4: Enable CORS
curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/httpd/enable_cors" \
  -H "Content-Type: application/json" -d '"true"' --user "${AUTH}"

curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/chttpd/enable_cors" \
  -H "Content-Type: application/json" -d '"true"' --user "${AUTH}"

# Step 5: Increase max sizes (needed for large vaults)
curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/chttpd/max_http_request_size" \
  -H "Content-Type: application/json" -d '"4294967296"' --user "${AUTH}"

curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/couchdb/max_document_size" \
  -H "Content-Type: application/json" -d '"50000000"' --user "${AUTH}"

# Step 6: CORS credentials and allowed origins for Obsidian
curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/cors/credentials" \
  -H "Content-Type: application/json" -d '"true"' --user "${AUTH}"

curl -sf -X PUT "${LOCAL}/_node/${NODE}/_config/cors/origins" \
  -H "Content-Type: application/json" \
  -d '"app://obsidian.md,capacitor://localhost,http://localhost"' \
  --user "${AUTH}"

echo "[init] CouchDB configuration complete!"