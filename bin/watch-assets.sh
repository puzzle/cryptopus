#!/bin/bash

filename="frontend/dist/assets/frontend.js"

watchFile() {
    local filename="$1"
    local m1=$(md5sum "$filename")

    while true; do
        sleep 10
        local m2=$(md5sum "$filename")
        echo ""
        echo "$m1"
        echo "$m2"
        if [ "$m1" != "$m2" ] ; then
            m1=$m2
            rm -f public/frontend-index-test.html
            cp -rf frontend/dist/* public/
            cp public/{index,frontend-index-test}.html
            cp public/{index,frontend-index-development}.html
            echo "Refreshed frontend"
        fi
    done
}

watchFile "$filename"