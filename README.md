## commandes utiles 

ajouter usr dans un group
    usermod -aG nomgroup nomusr

comment voir les images 
    docker images
    -> le U signifie in use

les details de l'images (layers)
    docker history nomdelimage

voir les process en cours
    ps -ef | grep docker
    docker ps

et les process qui ont tourne et maintenant arretes 
    docker ps -a

pour arreter un process 
    docker stop nomdelimage
    docker kill nomdelimage (plus brutal)

pour supprimer les dockers arrete 
    docker rm nom(pas de l'image, mais derniere colonne) ou ID
    
    CONTAINER ID   IMAGE     COMMAND                CREATED         STATUS                     PORTS     NAMES
    df8d6fcfc280   test1     "echo ' hello guys'"   5 minutes ago   Exited (0) 5 minutes ago             relaxedbabbage


pour que le name ne soit pas aleatoire 
    docker run --name nomchoisit nomdelimage

pour lancer un process en arriere plan
    docker run -d nomdelimage

Rentrer dans le conteneur avec un shell interactif
    docker exec -it monconteneur bash
    
    -it = mode interactif (-i) + terminal (-t), pour avoir un vrai shell utilisable, pas juste une commande qui s'exécute et se termine
    monconteneur = le nom qu'on a donné avec --name
    bash = la commande à exécuter à l'intérieur (ici, ouvrir un shell bash)

Supprimer les images 
    docker rmi nomdelimage
    docker image prune (ne fonctionne que dans le cas ou elles sont orphelines, plus de tag associer)


installation de la db
    docker run --rm testmaria mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    il est possible que le apt install mariadb-server initialise deja /var/lib/mysql. Dans ce cas on recoit un message >
        mysql.user table already exists!
        Run mariadb-upgrade, not mariadb-install-db
    
    pour s'assurer que les fichiers sont bien dans le container
        docker run --rm testmaria ls /var/lib/mysql

run la db
    docker run --rm -d --name testmariadb testmaria mysqld_safe

    pour voir si ca tourne bien 
    docker ps
    
    pour voir les logs
    docker logs nomattribue

pour se connecter a la db en tant que user msql
    docker exec -it testmariadb mysql

    et montrer la database
        SHOW DATABASES;

    pour sortir 
        exit;

    creer une database 
        CREATE DATABASE nomdeladb;

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.002 sec)

MariaDB [(none)]> CREATE DATABASE wordpress;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpress          |
+--------------------+
5 rows in set (0.001 sec)
