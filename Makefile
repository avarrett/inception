NAME=inception

DATA_DIR=$(HOME)/data

DC=srcs/docker-compose.yml
DB_DATA=$(DATA_DIR)/mariadb
WP_DATA=$(DATA_DIR)/wordpress

all: setup build up

setup:
	@echo "Setting up directories"
	@mkdir -p $(DB_DATA)
	@mkdir -p $(WP_DATA)
	@echo "Directories are setup"

build:
	@echo "Building images with docker-compose"
	@docker compose -f $(DC) build
	@echo "Building done"

up:
	@echo "Construction of containers"
	@docker compose -f $(DC) up
	@echo "Containers are up"

up-d:
	@echo "Construction of containers"
	@docker compose -f $(DC) up -d
	@echo "Containers are up"

bl:
	@echo "Building images and launch containers"
	@docker compose -f $(DC) up --build

down-v: 
	@echo "Stopping containers and removing volumes"
	@docker compose -f $(DC) down -v
	@echo "Containers and volumes are removed"

down: clean

re: fclean all

clean:
	@echo "Removing containers"
	@docker compose -f $(DC) down
	@echo "Containers stopped"

fclean:
	@echo "Removing containers, images, volumes, and data"
	@docker compose -f $(DC) down -v --rmi all
	@sudo rm -rf $(DB_DATA)
	@sudo rm -rf $(WP_DATA)
	@echo "Cleaning done"
  
logs:
	@echo "Looking for logs"
	@docker compose -f $(DC) logs 

image:
	@echo "Looking for images"
	@docker compose -f $(DC) images

ps:
	@docker compose -f $(DC) ps

.PHONY: setup build up up-d bl down down-v logs image clean fclean re ps
