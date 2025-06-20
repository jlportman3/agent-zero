IMAGE=agent-zero-run:local
CONTAINER=agent-zero
DATA_DIR=/mypool/agent-zero-data
PORT=50080

build:
	docker build -f docker/myrun/Dockerfile -t $(IMAGE) .

run: build
	docker run --gpus all --name $(CONTAINER) -p $(PORT):80 -v $(DATA_DIR):/a0 $(IMAGE) $(ARGS)

compose-up:
	docker-compose -f docker/myrun/docker-compose.yml up

compose-down:
	docker-compose -f docker/myrun/docker-compose.yml down

.PHONY: build run compose-up compose-down
