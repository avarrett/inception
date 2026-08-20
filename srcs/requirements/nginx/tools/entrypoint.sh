#!/bin/bash

if [ ! -f /etc/nginx/ssl/inception.crt ]; then
	mkdir -p /etc/nginx/ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=CH/ST=Vaud/L=Renens/O=42/CN=${DOMAIN_NAME}"
fi

until nc -z wordpress 9000; do
	sleep 1;
done

echo "php-fpm is ready"

exec nginx -g "daemon off;"
