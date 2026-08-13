#!/bin/bash

#set -e permet d'arreter le script si jamais il plante 
set -e


if [ ! -d /var/lib/mysql/mysql ]; then
	echo "First initialisation of mariadb"
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

if [ ! -d /var/lib/mysql/wordpress ]; then
	echo "Initisalisation"
	mysqld_safe --datadir=/var/lib/mysql &

	until mysqladmin ping --silent; do 
		echo "Waiting for mariadb to be ready"
		sleep 1;
	done

	DB_PSWD=$(cat /run/secrets/db_password)
	DB_ROOT_PSWD=$(cat /run/secrets/db_root_password)

	mysql -u root <<-EOSQL
		CREATE DATABASE IF NOT EXISTS ${DB_NAME};
		CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PSWD}';
		GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PSWD}';
		FLUSH PRIVILEGES;
EOSQL

	mysqladmin -u root -p"${DB_ROOT_PSWD}" shutdown
	echo "Initialisation done"

else
	echo "Initialisation of mariadb already done"
fi

exec mysqld_safe --datadir=/var/lib/mysql
