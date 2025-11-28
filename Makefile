APP=src.todo_api.main:app
VENV=venv

# Variables
DOCKER_COMPOSE = docker-compose
DOCKER = docker
CONTAINER_NAME = todo_api_app
IMAGE_NAME = todo-api
SERVICE_NAME = todo-api

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help build up down restart logs shell test clean rebuild ps health stop start
help:
	@echo -e "$(GREEN)Available commands:$(NC)"
	@echo -e "$(YELLOW)make setup$(NC)        - Set up the Python virtual environment and install dependencies"
	@echo -e "$(YELLOW)make run$(NC)          - Run the FastAPI application with Uvicorn"
	@echo -e "$(YELLOW)make clean$(NC)        - Remove the virtual environment and temporary files"

setup:
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt

run: $(VENV)/bin/uvicorn
	PYTHONPATH=./src $(VENV)/bin/uvicorn $(APP) --reload

clean:
	rm -rf $(VENV) *.db
	find . -type d -name "__pycache__" -exec rm -rf {} +

build: ## Build Docker image
	@echo "$(GREEN)Building Docker image...$(NC)"
	$(DOCKER_COMPOSE) build

up: ## Start containers in detached mode
	@echo "$(GREEN)Starting containers...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Containers started!$(NC)"
	@echo "API available at: http://localhost:8000"
	@echo "API docs at: http://localhost:8000/docs"

down: ## Stop and remove containers
	@echo "$(YELLOW)Stopping containers...$(NC)"
	$(DOCKER_COMPOSE) down

restart: ## Restart containers
	@echo "$(YELLOW)Restarting containers...$(NC)"
	$(DOCKER_COMPOSE) restart

logs: ## Show logs (follow mode)
	$(DOCKER_COMPOSE) logs -f

clean: ## Remove containers, images, and volumes
	@echo "$(RED)Cleaning up Docker resources...$(NC)"
	$(DOCKER_COMPOSE) down -v --rmi local
	@echo "$(GREEN)Cleanup complete!$(NC)"

rebuild: ## Rebuild and restart containers
	@echo "$(YELLOW)Rebuilding containers...$(NC)"
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Rebuild complete!$(NC)"

prod-build: ## Build for production
	@echo "$(GREEN)Building production image...$(NC)"
	$(DOCKER) build -t $(IMAGE_NAME):latest -t $(IMAGE_NAME):$$(date +%Y%m%d-%H%M%S) .
