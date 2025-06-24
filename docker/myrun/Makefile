IMAGE=agent-zero-run:local
BASE_IMAGE=agent-zero-base:local
CONTAINER=agent-zero
DATA_DIR=/mypool/agent-zero-data
PORT=50080

CACHE_DATE ?= $(shell date +%Y-%m-%d:%H:%M:%S)

build:
	rm -rf ./fs
	cp -R ../run/fs .
	docker compose -f docker-compose.yml build \
		--build-arg BRANCH=development \
		--build-arg CACHE_DATE=$(CACHE_DATE)

rebuild: clean
	rm -rf ./fs
	cp -R ../run/fs .
	docker compose -f docker-compose.yml build --no-cache \
		--build-arg BRANCH=development \
		--build-arg CACHE_DATE=$(shell date +%Y-%m-%d:%H:%M:%S)

run: build
	docker compose -f docker-compose.yml up -d

up:
	docker compose -f docker-compose.yml up -d

down:
	docker compose -f docker-compose.yml down

clean:
	docker container prune -f
	docker image prune -af

build-base:
	docker build -t $(BASE_IMAGE) ../base

.PHONY: build-base build run up down clean rebuild
