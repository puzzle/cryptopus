#!/bin/bash
rm -r public/{frontend-index.html,assets}

rm frontend/markdown/CHANGELOG.md
ln -s ../../CHANGELOG.md frontend/markdown
ln -s ../frontend/dist/assets public/
ln -s ../frontend/dist/index.html public/frontend-index.html
