FROM debian:trixie

RUN apt update && apt install -y nginx openssl netcat-openbsd

# Dans le cas ou nous avons qu'un seul site a faire tourner on peut se permettre d'ecraser le default
# Il possede deja un lien symbolique qui nous evite de creer un config et set-up le lien avec /etc/nginx/site-enable/${config_correspondante}

	#COPY conf/nginx.conf /etc/nginx/sites-available/wordpress.conf
	#RUN ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled/wordpress.conf

COPY /conf/nginx.conf /etc/nginx/sites-available/default

COPY /tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
