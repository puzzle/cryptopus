#!/bin/bash
cp CHANGELOG.md frontend/markdown/
yarn --cwd frontend/ install
yarn --cwd frontend/ build-prod
rm public/frontend-index.html
rsync --ignore-existing -r frontend/dist/* public/
mv public/{index,frontend-index}.html
