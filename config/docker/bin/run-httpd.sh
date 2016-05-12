#!/bin/bash

rm -rf $APACHE_PID_FILE

# use pipe due to error in Docker 1.8
mkfifo -m 777 /tmp/logpipe
cat < /tmp/logpipe 1>&2 &
# Use libmapuid to map ose generate uid for passenger to correct passwd entry
# otherwise the following error occurs:
# Cannot checkout session due to Passenger::RuntimeException:
# Cannot get user database entry for user UID 1000190000; it looks like your system's user database is broken, please fix it.
export LD_PRELOAD=/usr/local/lib/libmapuid.so

exec /usr/sbin/apachectl -DFOREGROUND 
