#!/bin/bash
rm -f public/frontend-index-test.html
cp -rf frontend/dist/* public/
mv public/{index,frontend-index-test}.html
