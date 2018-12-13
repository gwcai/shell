#!/bin/bash

echo "create user:postgres"
USER_COUNT=`cat /etc/passwd | grep '^postgres:' -c`
USER_NAME='postgres'
if [ $USER_COUNT -ne 1 ]
    then
    useradd $USER_NAME
    echo "postgres" | passwd $USER_NAME --stdin
    else
    echo 'user postgres exists!'
fi

echo "decompress postgresql:"
tar -zxf postgresql-9.6.5-1-linux-x64-binaries.tar.gz -C /usr

echo "mkdir /opt/postgresql/9.6/data  logs"
mkdir /opt/postgres
mkdir /opt/postgres/9.6
mkdir /opt/postgres/9.6/data
mkdir /opt/postgres/9.6/logs

echo "change user/group to postgres"
chown -R postgres:postgres /usr/pgsql
chown -R postgres:postgres /opt/postgres

echo "add to service:"
mv -f cloud_conf /DSSPHOME/.
mv -f /gfire/autostart/* /etc/init.d/.
chmod a+x /etc/init.d/*
chkconfig --add /etc/init.d/postgresql-9.6
chkconfig --add /etc/init.d/services

echo "add environment path"
PG_HOME=/data/pgsql
PGDATA=/opt/postgres/9.6/data
FILE=/etc/profile

sed -i '$a export PG_HOME='$PG_HOME $FILE
sed -i '$a export PGDATA='$PGDATA $FILE
sed -i '$a export PATH=$PATH:$PG_HOME/bin' $FILE
source $FILE

su postgres
echo "init postgresql"
/usr/pgsql/bin/initdb -D /opt/postgres/9.6/data

PG_HBA_CONF=/opt/postgres/9.6/data/pg_hba.conf
POSTGRESQL_CONF=/opt/postgres/9.6/data/postgresql.conf
echo "edit pg_hba.conf"
sed -i '86a host        all             all              0.0.0.0/0               md5' $PG_HBA_CONF
echo "edit postgresql.conf"
sed -i '59i listen_addresses = '\''*'\''' $POSTGRESQL_CONF

echo "start postgresql"
/usr/pgsql/bin/pg_ctl -D /opt/postgres/9.6/data -l /opt/postgres/9.6/logs/postgres.log start

echo "set password of dbuser postgres: "
psql