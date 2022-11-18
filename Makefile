.DEFAULT_GOAL := help
PWD = $(shell realpath $(dir $(lastword $(MAKEFILE_LIST))))
.PHONY: init lint test help

init: linter tester ## init

tester: ## clone tester
	git clone https://github.com/thinca/vim-themis

test: ## testing with vim-themis
	export VIMSIDIAN_TEST_PATH=$(PWD)/test/vault; ./vim-themis/bin/themis --reporter spec -r test

linter: ## clone linter
	git clone https://github.com/ynkdir/vim-vimlparser
	git clone https://github.com/syngan/vim-vimlint

lint: ## linting with vimlint
	./vim-vimlint/bin/vimlint.sh -l ./vim-vimlint -p ./vim-vimlparser -e EVL102.l:_=1 -c func_abort=1 autoload plugin test 2>&1

lint-vint: check-vint ## linting with vint
	vint plugin autoload test

vint-int: ## install vint using pip
	pip install vint

check-vint: ## check vint command exsits
	which "vint" > /dev/null 2>&1; if [ $$? -gt 0 ]; then exit 1; fi

help: ### help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
