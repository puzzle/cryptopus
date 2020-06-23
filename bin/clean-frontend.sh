#!/bin/bash
sed -i 's/\/ember/http:\/\/localhost:4200/g' frontend/app/index.html
vendorjs="$(grep -oP '(?<=<script src="assets\/)vendor-[a-z|\d]{32}.js' public/ember/index.html)"
vendorcss="$(grep -oP '(?<=<link integrity="" rel="stylesheet" href="assets\/)vendor-[a-z|\d]{32}.css' public/ember/index.html)"
frontendjs="$(grep -oP '(?<=<script src="assets\/)frontend-[a-z|\d]{32}.js' public/ember/index.html)"
frontendcss="$(grep -oP '(?<=<link integrity="" rel="stylesheet" href="assets\/)frontend-[a-z|\d]{32}.css' public/ember/index.html)"
sed -i "s/$vendorjs/vendor.js/g" frontend/app/index.html
sed -i "s/$vendorcss/vendor.css/g" frontend/app/index.html
sed -i "s/$frontendjs/frontend.js/g" frontend/app/index.html
sed -i "s/$frontendcss/frontend.css/g" frontend/app/index.html

# Remove ember source
rm -rf public/ember/
