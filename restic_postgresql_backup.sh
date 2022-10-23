#!/bin/bash


pushd $(dirname $0)
. ./restic_env.sh

TAG=postgresql
CONTAINER_NAME=postgres
USER=esbenab@gmail.com


for DB in $(docker exec $CONTAINER_NAME psql -l -U $USER | awk '{print $1}' | grep -Ev "^(List|Name|-*\+|postgres|template|\||\(|$)") 
do
	docker exec $CONTAINER_NAME pg_dump -U $USER --create --clean --if-exists --no-owner --no-privileges $DB | \
		gzip --rsyncable | \
		restic backup \
			--stdin --stdin-filename postgresql/$DB.sql.gz \
			--tag "$TAG" \
			--tag "$DB"
done
popd
