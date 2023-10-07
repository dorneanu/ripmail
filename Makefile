live-docs:
	@echo "Starting structurizr/lite"
	docker run -it --rm -p 1337:8080 -v ./docs/c4/:/usr/local/structurizr structurizr/lite
