IMAGE_NAME?=agent-zero-run
TAG?=local
CONTAINER_NAME?=agent-zero
VOLUME?=/mypool/agent-zero-data:/a0

build:
	docker build -t $(IMAGE_NAME):$(TAG) -f Dockerfile ../..

run:
	docker run --gpus all --name $(CONTAINER_NAME) -p 50080:80 -v $(VOLUME) $(IMAGE_NAME):$(TAG) $(ARGS)

compose-up:
	docker compose up -d

compose-down:
	docker compose down

.PHONY: build run compose-up compose-down
