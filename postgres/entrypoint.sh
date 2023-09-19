#!/bin/bash

set -e
echo "PostgreSQL starting..."

# Disable log messages 
command >/dev/null 2>&1 

# Execute your init scripts here 

# PostgreSQL hizmetini başlat
service postgresql start
sleep 5

# "test" adında bir veritabanı oluştur
su - postgres -c "psql -U postgres -c 'CREATE DATABASE test;'"
# "test" veritabanına bağlan ve init.sql dosyasını çalıştır
su - postgres -c 'psql -U postgres -d test -f /home/mock/init.sql'

echo "PostgreSQL started success"

node /root/ide/src-gen/backend/main.js --hostname=0.0.0.0 --port=3030 --plugins=local-dir:/root/ide/plugins
