runtest:
	@echo "please install the foundry first"
	@echo "Running tests..."
	forge build
	forge compile
	forge test -vvv

# TODO: add demo
demo:
	@echo "please install the foundry first"
	@echo "Running demo..."
