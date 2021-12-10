#!/bin/bash

. /docker-entrypoint-common.sh $1

echo "********* Starting UWSGI... *********"
uwsgi --chdir /srv/curator/ \
      --uid cdcs \
      --gid cdcs \
      --socket /tmp/curator/curator.sock \
      --wsgi-file /srv/curator/$PROJECT_NAME/wsgi.py \
      --chmod-socket=666 \
      --processes=$UWSGI_PROCESSES \
      --enable-threads \
      --lazy-apps
echo "UWSGI started"
