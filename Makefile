NAME=inception

DATA_DIR=$(HOME)/data 

DC=/srcs/docker-compose.yml
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

bl:
	@echo "Building images and launch containers"
	@docker compose -f $(DC) up --build

down:
	@echo "Removing containers and images"
	@docker compose -f $(DC) down -v --rmi all
	@echo "Cleaning done"
  
logs:
	@echo "Looking for logs"
	@docker compose -f $(DC) logs 

image:
	@echo "Looking for images"
	@docker compose -f $(DC) images

.PHONY: setup build up bl down logs image
