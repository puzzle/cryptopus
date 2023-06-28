#!/bin/bash
export NODE_OPTIONS=--openssl-legacy-provider && npm install --prefix frontend/
export NODE_OPTIONS=--openssl-legacy-provider && npm run build-prod --prefix frontend/
rm public/frontend-index.html
rsync --ignore-existing -r frontend/dist/* public/
mv public/{index,frontend-index}.html
