# Documentation développeur — Inception

## 1. Mettre en place l'environnement depuis zéro

### Prérequis

- Une VM Debian (12/13) avec Docker et le plugin Docker Compose v2 installés
- `sudo docker --version` et `sudo docker compose version` doivent répondre correctement

Installation de Docker (méthode officielle) :

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### Structure du projet

```
inception/
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── wp_admin_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── entrypoint.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── entrypoint.sh
        └── nginx/
            ├── Dockerfile
            ├── conf/
            │   └── nginx.conf
            └── tools/
                └── entrypoint.sh
```

### Fichiers de configuration à préparer avant le premier build

**`srcs/.env`** — variables non sensibles, partagées entre services :

```env
DB_NAME=wordpress
DB_USER=wpuser
WP_ADMIN_USER=<login_non_generique>
WP_ADMIN_EMAIL=admin@example.com
DOMAIN_NAME=<login>.42.fr
```

**`secrets/*.txt`** — un mot de passe par fichier, sans retour à la ligne superflu :

```bash
mkdir -p secrets
echo "motdepasse_db" > secrets/db_password.txt
echo "motdepasse_root" > secrets/db_root_password.txt
echo "motdepasse_admin" > secrets/wp_admin_password.txt
```

⚠️ Le dossier `secrets/` doit figurer dans `.gitignore` — ces fichiers ne sont jamais commités.

## 2. Builder et lancer le projet

### Via Docker Compose directement

```bash
cd srcs
docker compose up --build
```

### Via le Makefile (si présent à la racine du projet)

```bash
make          # build + up
make down     # arrête les conteneurs, conserve les volumes
make clean    # down + suppression des images
make fclean   # clean + suppression des volumes (perte de données)
make re       # fclean + build complet
```

## 3. Commandes utiles pour gérer conteneurs et volumes

### Conteneurs

```bash
docker compose ps                      # état des services
docker compose logs <service> -f       # logs en direct
docker exec -it <service> bash         # shell interactif dans un conteneur
docker compose restart <service>       # redémarre un seul service
docker compose build --no-cache <service>   # rebuild sans cache
```

### Debug réseau entre conteneurs

```bash
# Depuis nginx, vérifier que php-fpm répond
docker exec -it nginx nc -z wordpress 9000

# Depuis wordpress, vérifier que MariaDB répond
docker exec -it wordpress mysql -h mariadb -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1"
```

### Volumes

```bash
docker volume ls                       # lister les volumes
docker volume inspect <nom_du_volume>  # voir le point de montage réel sur l'hôte
```

Suppression complète (⚠️ perte de données) :

```bash
docker compose down -v
```

## 4. Où sont stockées les données, et comment elles persistent

Chaque service dont les données doivent survivre à un redémarrage de conteneur utilise un **volume monté en bind mount**, pointant vers un dossier réel de la machine hôte :

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${HOME}/data/mariadb
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${HOME}/data/wordpress
```

| Volume | Monté sur (dans le conteneur) | Contient |
|---|---|---|
| `mariadb_data` | `/var/lib/mysql` | Toutes les tables MariaDB (comptes, articles, réglages WordPress) |
| `wordpress_data` | `/var/www/html` | Le code WordPress, les fichiers uploadés, `wp-config.php` |

### Point d'attention critique

Les deux volumes doivent être conservés **ensemble et de façon cohérente**. Si l'un persiste et pas l'autre (par exemple `wordpress_data` conservé mais `mariadb_data` recréée vide), WordPress trouvera sa configuration existante mais aucune donnée en base correspondante — le site redirigera systématiquement vers l'écran d'installation.

### Logique d'initialisation (idempotence)

Chaque `entrypoint.sh` vérifie, à chaque démarrage, si son service a déjà été initialisé avant de relancer une configuration complète :

- **mariadb** : vérifie l'existence de `/var/lib/mysql/mysql` (tables système) puis `/var/lib/mysql/wordpress` (base applicative)
- **wordpress** : vérifie l'existence de `/var/www/html/wp-config.php`

Si le fichier/dossier existe déjà, l'entrypoint saute directement au lancement du service en foreground, sans réinitialiser quoi que ce soit.

## 5. Points de configuration réseau notables

- `mariadb` : `bind-address = 0.0.0.0` dans `50-server.cnf`, pour accepter les connexions depuis les autres conteneurs (pas seulement `localhost`)
- `wordpress` (php-fpm) : `listen = 0.0.0.0:9000` dans `www.conf`, au lieu du socket Unix par défaut, pour être joignable via le réseau Docker par nginx
- `nginx` : `fastcgi_pass wordpress:9000;` — résolution du conteneur `wordpress` par son nom de service (DNS interne Docker Compose)

Seul `nginx` expose un port vers l'hôte (`443:443`). `mariadb` et `wordpress` n'ont volontairement aucune section `ports:` — ils ne sont accessibles que depuis le réseau Docker interne.
