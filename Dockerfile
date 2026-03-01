FROM budibase/couchdb

COPY init-couchdb.sh /init-couchdb.sh

# Run init script in background, then start CouchDB normally
ENTRYPOINT ["/bin/bash", "-c", "chmod +x /init-couchdb.sh && /init-couchdb.sh & exec /opt/couchdb/bin/couchdb"]
