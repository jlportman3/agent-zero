IMAGE=agent-zero-run:local
CONTAINER=agent-zero
DATA_DIR=/mypool/agent-zero-data
PORT=50080
# Build context root (repository root)
ROOT_DIR:=$(abspath $(CURDIR)/../..)

build:
       docker build -f $(CURDIR)/Dockerfile -t $(IMAGE) $(ROOT_DIR)

run: build
	docker run --gpus all --name $(CONTAINER) -p $(PORT):80 -v $(DATA_DIR):/a0 $(IMAGE) $(ARGS)

compose-up:
       docker-compose -f $(CURDIR)/docker-compose.yml up

compose-down:
       docker-compose -f $(CURDIR)/docker-compose.yml down

.PHONY: build run compose-up compose-down
