FROM couchdb:3

# Copy config directly into local.d - this is the official recommended approach
# CouchDB reads all .ini files in this directory on startup automatically
COPY local.ini /opt/couchdb/etc/local.d/obsidian.ini