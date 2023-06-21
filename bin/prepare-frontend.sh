#!/bin/bash
export NODE_OPTIONS=--openssl-legacy-provider && yarn --cwd frontend/ install
export NODE_OPTIONS=--openssl-legacy-provider && yarn --cwd frontend/ build-prod
rm public/frontend-index.html
rsync --ignore-existing -r frontend/dist/* public/
mv public/{index,frontend-index}.html
