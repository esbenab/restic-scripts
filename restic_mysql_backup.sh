#!/bin/bash


pushd $(dirname $0)
source $HOME/docker/general.env
. ./restic_env.sh

TAG=mysql
CONTAINER_NAME=mariadb


for DB in $(docker exec $CONTAINER_NAME mysql -uroot -p${MARIADB_DEFAULT_PASSWORD} -BNe 'show databases' | grep -Ev --line-regexp 'mysql|information_schema|performance_schema|sys')
do
	docker exec $CONTAINER_NAME mysqldump -uroot -p${MARIADB_DEFAULT_PASSWORD}  --skip-dump-date --force $DB | \
		gzip --rsyncable | \
		restic backup \
			--stdin --stdin-filename mysql/$DB.sql.gz \
			--tag "$TAG" \
			--tag "$DB"
done
popd
