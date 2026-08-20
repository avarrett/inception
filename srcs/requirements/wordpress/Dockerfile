FROM debian:bookworm

RUN apt update && \
	apt install -y \
	php-fpm \
	php-mysqli \
	php-gd \
    	php-xml \
    	php-mbstring \
    	default-mysql-client \
	curl

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY /conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY /tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]


