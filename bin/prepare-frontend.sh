#!/bin/bash
yarn --cwd frontend/ install
yarn --cwd frontend/ build-prod
mkdir public/ember
mv -v frontend/dist/* public/ember/

# Replace ember source
sed -i 's/http:\/\/localhost:4200\/app/\/ember/g' frontend/app/index.html
vendorjs="$(grep -oP '(?<=<script src="assets\/)vendor-[a-z|\d]{32}.js' public/ember/index.html)"
vendorcss="$(grep -oP '(?<=<link integrity="" rel="stylesheet" href="assets\/)vendor-[a-z|\d]{32}.css' public/ember/index.html)"
frontendjs="$(grep -oP '(?<=<script src="assets\/)frontend-[a-z|\d]{32}.js' public/ember/index.html)"
frontendcss="$(grep -oP '(?<=<link integrity="" rel="stylesheet" href="assets\/)frontend-[a-z|\d]{32}.css' public/ember/index.html)"
sed -i "s/vendor.js/$vendorjs/g" frontend/app/index.html
sed -i "s/vendor.css/$vendorcss/g" frontend/app/index.html
sed -i "s/frontend.js/$frontendjs/g" frontend/app/index.html
sed -i "s/frontend.css/$frontendcss/g" frontend/app/index.html
