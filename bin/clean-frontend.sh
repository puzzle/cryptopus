#!/bin/bash
sed -i 's/\/ember/http:\/\/localhost:4200\/app/g' app/views/layouts/application.html.haml
vendorjs="$(grep -oP '(?<=<script src="\/app\/assets\/)vendor-[a-z|\d]{32}.js' public/ember/index.html)"
vendorcss="$(grep -oP '(?<=<link integrity="" rel="stylesheet" href="\/app\/assets\/)vendor-[a-z|\d]{32}.css' public/ember/index.html)"
frontendjs="$(grep -oP '(?<=<script src="\/app\/assets\/)frontend-[a-z|\d]{32}.js' public/ember/index.html)"
frontendcss="$(grep -oP '(?<=<link integrity="" rel="stylesheet" href="\/app\/assets\/)frontend-[a-z|\d]{32}.css' public/ember/index.html)"
sed -i "s/$vendorjs/vendor.js/g" app/views/layouts/application.html.haml
sed -i "s/$vendorcss/vendor.css/g" app/views/layouts/application.html.haml
sed -i "s/$frontendjs/frontend.js/g" app/views/layouts/application.html.haml
sed -i "s/$frontendcss/frontend.css/g" app/views/layouts/application.html.haml

# Remove ember source
rm -rf public/ember/
