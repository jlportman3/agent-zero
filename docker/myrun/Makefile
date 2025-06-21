IMAGE=agent-zero-run:local
CONTAINER=agent-zero
DATA_DIR=/mypool/agent-zero-data
PORT=50080

build:
	rm -rf ./agent-zero
	rm -rf ./fs
	cp -R ../run/agent-zero .
	cp -R ../run/fs .
	docker build -t agent-zero-run:local --build-arg BRANCH=development --no-cache  .

run: build
	docker run --gpus all --name $(CONTAINER) -p $(PORT):80 -v $(DATA_DIR):/a0 $(IMAGE) $(ARGS)

up:
	docker compose -f docker-compose.yml up

down:
	docker compose -f docker-compose.yml down
:q

.PHONY: build run compose-up compose-down
