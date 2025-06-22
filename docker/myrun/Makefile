IMAGE=agent-zero-run:local
CONTAINER=agent-zero
DATA_DIR=/mypool/agent-zero-data
PORT=50080

CACHE_DATE ?= $(shell date +%Y-%m-%d:%H:%M:%S)

build: clean
	rm -rf ./fs
	cp -R ../run/fs .
	docker build -t $(IMAGE) --build-arg BRANCH=development --build-arg CACHE_DATE=$(CACHE_DATE) .

rebuild: clean
	rm -rf ./fs
	cp -R ../run/fs .
	docker build --no-cache -t $(IMAGE) --build-arg BRANCH=development --build-arg CACHE_DATE=$(shell date +%Y-%m-%d:%H:%M:%S) .

run: build
	docker run --gpus all --name $(CONTAINER) -p $(PORT):80 -v $(DATA_DIR):/a0 $(IMAGE) $(ARGS)

up:
	docker compose -f docker-compose.yml up

down:
	docker compose -f docker-compose.yml down

clean:
	docker container prune -f
	docker image prune -af


.PHONY: build run compose-up compose-down
