IMAGE=agent-zero-run:local
CONTAINER=agent-zero
DATA_DIR=/mypool/agent-zero-data
PORT=50080

build: clean
	rm -rf ./fs
	cp -R ../run/fs .
	docker build -t agent-zero-run:local --build-arg BRANCH=development --no-cache  .

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
