FROM debian:trixie

RUN apt update && apt install -y mariadb-server

COPY /tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT ["entrypoint.sh"]
