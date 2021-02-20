help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	bundle install

test: ## Test application
	rm -f db/test.sqlite3
	bundle exec rspec

lint: ## Check file format, smell code, conventions…
	bundle exec rubocop

lint-fix: ## Fix violations when possible
	bundle exec rubocop -a

install-locally: ## Install this gem locally
	bundle exec rake install