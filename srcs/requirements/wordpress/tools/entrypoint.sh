#!/bin/bash
set -e

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Configuration of wordpress"
	
	mkdir -p /var/www/html
	cd /var/www/html

	DB_PSWD=$(cat /run/secrets/db_password)
	WP_ADM_PSWD=$(cat /run/secrets/wp_admin_password)
	
	until mysql -h mariadb -u"${DB_USER}" -p"${DB_PSWD}" -e "SELECT 1" > /dev/null 2>&1; do 
		sleep 1;
	done
	echo "Mariadb is ready"
	
	wp core download --allow-root

	wp config create \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PSWD}" \
		--dbhost="mariadb" \
		--allow-root

	wp core install \
		--url="https://192.168.64.6" \
		--title="Inception" \
		--admin_user="${WP_ADM_USER}" \
		--admin_password="${WP_ADM_PSWD}" \
		--admin_email="${WP_ADM_EMAIL}" \
		--allow-root

else
	echo "Installation of Wordpress already done, let's skip this part"
fi

chown -R www-data:www-data /var/www/html

exec php-fpm8.4 -F
