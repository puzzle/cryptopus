#!/bin/bash
rm -r public/{frontend-index.html,assets}

ln -s ../frontend/dist/assets public/
ln -s ../frontend/dist/index.html public/frontend-index.html
