runtest:
	@echo "please install the foundry first"
	@echo "Running tests..."
	forge build
	forge compile
	forge test -vvvv

# TODO: add demo
demo:
	@echo "please install the foundry first"
	@echo "Running demo..."
