#!/bin/bash

. /docker-entrypoint-common.sh $1

echo "********* Starting Gunicorn... *********"
gunicorn --bind 0.0.0.0:8000 \
         --workers 10 \
         $PROJECT_NAME.wsgi:application
echo "Gunicorn started"
