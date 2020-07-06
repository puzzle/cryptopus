#!/bin/bash
sed -i 's/\/ember/http:\/\/localhost:4200/g' app/views/frontend/index.html.haml
vendorjs="$(grep -oP '(?<=<script src="\/assets\/)vendor-[a-z|\d]{32}.js' public/ember/index.html)"
vendorcss="$(grep -oP '(?<=href="\/assets\/)vendor-[a-z|\d]{32}.css' public/ember/index.html)"
frontendjs="$(grep -oP '(?<=<script src="\/assets\/)frontend-[a-z|\d]{32}.js' public/ember/index.html)"
frontendcss="$(grep -oP '(?<=href="\/assets\/)frontend-[a-z|\d]{32}.css' public/ember/index.html)"
sed -i "s/$vendorjs/vendor.js/g" app/views/frontend/index.html.haml
sed -i "s/$vendorcss/vendor.css/g" app/views/frontend/index.html.haml
sed -i "s/$frontendjs/frontend.js/g" app/views/frontend/index.html.haml
sed -i "s/$frontendcss/frontend.css/g" app/views/frontend/index.html.haml

# Remove ember source
rm -rf public/ember/
