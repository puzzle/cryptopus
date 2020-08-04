#!/bin/bash
yarn --cwd frontend/ install
yarn --cwd frontend/ build-prod
rm -r public/{assets,frontend-index.html}
cp -r frontend/dist/* public/
mv public/{index,frontend-index}.html
