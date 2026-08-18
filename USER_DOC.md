# Documentation utilisateur — Inception

## 1. Vue d'ensemble des services

Ce projet fait tourner un site WordPress complet à travers trois conteneurs Docker séparés, qui communiquent entre eux sur un réseau privé :

| Service | Rôle |
|---|---|
| **nginx** | Point d'entrée unique du site. Sert les pages en HTTPS (port 443) et transmet les requêtes PHP à WordPress. |
| **wordpress** (php-fpm) | Exécute le code WordPress et génère les pages du site. |
| **mariadb** | Base de données qui stocke tout le contenu du site (articles, pages, utilisateurs, réglages). |

Seul le service **nginx** est accessible depuis l'extérieur (port 443). Les deux autres services ne communiquent qu'en interne, sur le réseau Docker.

## 2. Démarrer et arrêter le projet

Toutes les commandes se lancent depuis le dossier `srcs/` du projet.

### Démarrer le projet

```bash
cd srcs
docker compose up --build
```

Ou en arrière-plan (sans garder le terminal occupé) :

```bash
docker compose up --build -d
```

Le premier démarrage prend un peu plus de temps : les images sont construites, WordPress est téléchargé et installé, la base de données est initialisée. Les démarrages suivants sont plus rapides car ces étapes sont sautées si tout est déjà en place.

### Arrêter le projet

```bash
docker compose down
```

Cette commande arrête et supprime les conteneurs, **mais conserve les données** (articles, utilisateurs, base de données) grâce aux volumes persistants.

⚠️ **Attention** : la commande `docker compose down -v` supprime en plus les volumes, donc **toutes les données du site**. À utiliser uniquement si vous voulez repartir de zéro.

## 3. Accéder au site et à l'administration

### Site public

```
https://<nom_de_domaine_ou_IP>/
```

### Panneau d'administration WordPress

```
https://<nom_de_domaine_ou_IP>/wp-admin/
```

⚠️ Le certificat HTTPS utilisé est auto-signé (généré localement, pas délivré par une autorité reconnue). Le navigateur affichera donc un avertissement de sécurité au premier accès — c'est normal. Il faut accepter/continuer manuellement pour accéder au site.

## 4. Localiser et gérer les identifiants

Les mots de passe ne sont jamais stockés en clair dans le code ou les fichiers de configuration. Ils sont gérés via des **secrets Docker**, sous forme de fichiers texte séparés :

```
secrets/
├── db_password.txt          → mot de passe de l'utilisateur de la base WordPress
├── db_root_password.txt     → mot de passe root de MariaDB
└── wp_admin_password.txt    → mot de passe du compte administrateur WordPress
```

Pour consulter un mot de passe (par exemple pour se connecter à l'admin WordPress) :

```bash
cat secrets/wp_admin_password.txt
```

Le nom d'utilisateur administrateur est défini dans le fichier `docker-compose.yml` ou `.env`, sous la variable `WP_ADMIN_USER`.

⚠️ Le dossier `secrets/` ne doit **jamais** être partagé ou versionné dans Git.

## 5. Vérifier que les services fonctionnent correctement

### Vérifier l'état des trois conteneurs

```bash
docker compose ps
```

Chaque service doit apparaître avec le statut **Up**. Si un service affiche **Exited** ou redémarre en boucle, quelque chose ne va pas.

### Consulter les logs d'un service

```bash
docker compose logs mariadb
docker compose logs wordpress
docker compose logs nginx
```

Ajouter `-f` pour suivre les logs en direct :

```bash
docker compose logs -f wordpress
```

### Test rapide d'accessibilité du site

Depuis la machine qui héberge Docker :

```bash
curl -k https://localhost/
```

Une réponse contenant du HTML confirme que le site répond correctement. Une absence de réponse ou une erreur de connexion indique un problème à investiguer dans les logs.
