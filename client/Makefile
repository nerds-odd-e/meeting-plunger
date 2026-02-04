.PHONY: lint format

lint:
	@echo "Running Go linters..."
	@golangci-lint run ./...

format:
	@echo "Formatting Go code..."
	@gofmt -w -s .
	@goimports -w .
