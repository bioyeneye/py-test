APP=src.todo_api.main:app
VENV=venv

setup:
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt

run: $(VENV)/bin/uvicorn
	PYTHONPATH=./src $(VENV)/bin/uvicorn $(APP) --reload

clean:
	rm -rf $(VENV) *.db
	find . -type d -name "__pycache__" -exec rm -rf {} +
