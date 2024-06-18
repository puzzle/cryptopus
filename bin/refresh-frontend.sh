filename="frontend/dist/index.html"

m1=$(md5sum "$filename")

while true; do
  sleep 10
  m2=$(md5sum "$filename")

  if [ "$m1" != "$m2" ] ; then
    m1=$m2
    rm -f public/frontend-index-test.html
    cp -rf frontend/dist/* public/
    mv public/{index,frontend-index-test}.html
    echo "Refreshed frontend"
  fi
done
