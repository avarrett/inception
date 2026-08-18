*This project has been created as part of the 42 curriculum by [avarrett].*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small infrastructure made of several Docker containers, each running a single service, orchestrated together with Docker Compose, inside a virtual machine.

The stack built here serves a WordPress website through three containers:

- **nginx** — the only entry point of the infrastructure, serving the site over HTTPS (TLSv1.2/TLSv1.3 only) with a self-signed certificate.
- **wordpress** (php-fpm) — runs the WordPress code and generates the site's pages.
- **mariadb** — stores all the site's data (users, articles, settings).

Each service is built from a minimal Debian base image, with no pre-built service images and no `latest` tags, following the constraints of the subject. The whole stack is designed to restart automatically on failure and to persist its data across restarts.

## Instructions

### Prerequisites

- A Linux VM (Debian recommended) with Docker and the Docker Compose v2 plugin installed.
- A `secrets/` directory at the root of the project containing the required password files (see `DEV_DOC.md` for the exact list).

### Setup and execution

```bash
git clone <repo_url> inception
cd inception
```

Add a domain entry pointing to your machine's IP in `/etc/hosts` (host and/or VM, depending on where you access the site from):

```
<VM_IP>   <login>.42.fr
```

Build and start the whole stack:

```bash
make
```

Stop the stack (data is preserved):

```bash
make down
```

Full cleanup, including images and volumes (⚠ destroys all data):

```bash
make fclean
```

The website is then reachable at:

```
https://<login>.42.fr/
```

More detailed setup, day-to-day usage and administration commands are documented in `USER_DOC.md` and `DEV_DOC.md` at the root of the project.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Debian Wiki](https://wiki.debian.org/)
- [nginx documentation](https://nginx.org/en/docs/)
- [WP-CLI documentation](https://wp-cli.org/)
- [WordPress Codex](https://codex.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [OpenSSL documentation](https://docs.openssl.org/)

**Use of AI**: Claude (Anthropic) was used throughout this project as a learning and debugging aid — never to generate a ready-made solution to copy-paste. Concretely, it was used to: explain underlying concepts (images vs containers, layers, PID 1 and foreground processes, FastCGI, Docker networking, secrets vs environment variables) before any code was written; review and correct configuration files and scripts written by hand (Dockerfiles, `entrypoint.sh` scripts, `nginx.conf`, `docker-compose.yml`); help diagnose runtime errors by interpreting logs and suggesting targeted verification commands (e.g. permission issues, a socket vs TCP misconfiguration on php-fpm, a typo in an `include` directive, a missing persistent volume causing data loss on restart). All configuration files were written and tested manually, one step at a time, with each change verified in the terminal before moving to the next.

## Project description: Docker and project sources

The project is split into one directory per service under `srcs/requirements/`, each containing its own `Dockerfile`, configuration files (`conf/`) and startup script (`tools/entrypoint.sh`). Services are orchestrated with a single `docker-compose.yml`, sharing a dedicated Docker network and two persistent volumes (one for the WordPress files, one for the MariaDB data directory). Sensitive values (database and admin passwords) are injected as Docker secrets, mounted as read-only files, and never hardcoded or passed as plain environment variables. Each container's entrypoint script is idempotent: it initializes its service only on first startup (detected by checking for a marker file/directory) and simply relaunches the service in the foreground on subsequent restarts, so that it becomes PID 1 as required by the subject.

### Virtual Machines vs Docker

A virtual machine virtualizes an entire operating system on top of a hypervisor: it ships its own kernel, boots independently, and is fully isolated from the host, but at the cost of significant overhead in boot time, memory and disk usage. Docker containers, on the other hand, share the host's kernel and only isolate processes, filesystem and network through Linux namespaces and cgroups. This makes containers much lighter and faster to start, but they provide a weaker isolation boundary than a VM (a kernel-level exploit can potentially affect the host). In this project, a VM is used as the base environment (as required), and Docker containers run inside it — combining the strong isolation of the VM as an outer boundary with the lightness and reproducibility of containers for each individual service.

### Secrets vs Environment Variables

Environment variables (declared with `environment:` in Compose, or `-e` on the command line) are simple to use but are visible in plain text through `docker inspect`, in the container's process environment, and potentially in shell history or CI logs — acceptable for non-sensitive data such as a database name or a username. Docker secrets, by contrast, are mounted as read-only files inside `/run/secrets/` at runtime and are not exposed through `docker inspect` or the container's environment; they are the appropriate mechanism for values that must stay confidential, such as database and admin passwords. In this project, non-sensitive configuration (`DB_NAME`, `DB_USER`, `WP_ADMIN_USER`, etc.) is passed as environment variables, while all passwords are read from files under `/run/secrets/` inside each entrypoint script.

### Docker Network vs Host Network

With the default (or a custom bridge) Docker network, each container gets its own isolated network namespace and communicates with the others through a private virtual network, resolving peer containers by their service name via Docker's internal DNS (e.g. `wordpress` resolving to the WordPress container's internal IP). With host networking, a container shares the host's network stack directly, exposing all its ports on the host with no isolation. This project uses a dedicated bridge network (`inception`) connecting the three services: only nginx publishes a port to the host (`443:443`), while MariaDB and WordPress remain reachable exclusively from within that internal network, never directly from the outside — this network-level isolation is central to the security model of the infrastructure.

### Docker Volumes vs Bind Mounts

Docker-managed volumes are stored and managed by Docker itself, typically under `/var/lib/docker/volumes/`, without the user needing to know or manage the exact path on disk. Bind mounts instead map a specific, user-chosen directory on the host filesystem directly into the container. This project uses named volumes configured with the `local` driver and `bind` mount options, pointing explicitly to `${HOME}/data/mariadb` and `${HOME}/data/wordpress` — combining the declarative, named-volume syntax in `docker-compose.yml` with an explicit, predictable storage location on the host, as required by the subject. This ensures that database and WordPress data survive container recreation (`docker compose down` / `up`) as long as the underlying host directories are not deleted.
