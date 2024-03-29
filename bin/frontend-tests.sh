#!/usr/bin/env bash

export RAILS_PORT=3001
PID_FILE=tmp/pids/frontend-test-server.pid
SERVER=false

case $1 in
  's' | 'serve' | 'server')
    SERVER=true ;;
esac

rails server -e test -d -p $RAILS_PORT -P $PID_FILE
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

cd frontend
if [[ $SERVER == true ]]; then
  ember test --server
else
  ember test
fi
rc=$?
cd ..

kill -KILL $(cat $PID_FILE)

exit $rc
