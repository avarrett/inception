#!/bin/bash

until nc -z wordpress 9000; do 
	sleep 1;
done

echo "php-fpm is ready"

exec nginx -g "daemon off;"
