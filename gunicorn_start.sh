#!/bin/bash

NAME="NAME_APPLICATION"                                                  # Name of the application
DJANGODIR=/path/to/project/dir                              # Django project directory
SOCKFILE=/path/to/dir/with/gunicorn.sock      # we will communicte using this unix socket
SHAREDDIR=/path/to/shared/dir
USER=username                                           # the user to run as
GROUP=username                                          # the group to run as
NUM_WORKERS=3                                                   # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=config.settings          # which settings file should Django use
DJANGO_WSGI_MODULE=config.wsgi                  # WSGI module name

echo "Starting $NAME"

# Activate the virtual environment
cd $DJANGODIR
source $SHAREDDIR/venv/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH
export PYTHONPATH=mysql://user/pwd@localhost/database
export DJANGO_CONFIGURATION=Production

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec $SHAREDDIR/venv/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --log-level=debug \
  --bind=unix:$SOCKFILE

