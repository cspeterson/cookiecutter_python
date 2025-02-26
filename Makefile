SHELL := /bin/bash
DEPENDENCIES := venv/dependencies.timestamp
STATIC_PYLINT := venv/pylint.timestamp
STATIC_BLACK := venv/black.timestamp
STATIC_MYPY := venv/mypy.timestamp
PYTHON_FILES := $(shell find tests -path ./venv -prune -o -name '*.py' -print)
VENV := venv/venv.timestamp
BUILD_DIR := dist_$(VERSION)
BUILD := $(BUILD_DIR)/.build.timestamp
_WARN := "\033[33m[%s]\033[0m %s\n"  # Yellow text for "printf"
_TITLE := "\033[32m[%s]\033[0m %s\n" # Green text for "printf"
_ERROR := "\033[31m[%s]\033[0m %s\n" # Red text for "printf"

all: static-analysis test

$(VENV):
	python3 -m venv venv
	touch $(VENV)
$(DEPENDENCIES): $(VENV) requirements-make.txt
	# Install Python dependencies, runtime *and* test/build
	./venv/bin/pip3 install --upgrade pip
	./venv/bin/python3 -m pip install --requirement requirements-make.txt
	touch $(DEPENDENCIES)
.PHONY: dependencies
dependencies: $(DEPENDENCIES)

$(STATIC_BLACK): $(PYTHON_FILES) $(DEPENDENCIES)
	# Check style
	@./venv/bin/black --check $(PYTHON_FILES)
	@touch $(STATIC_BLACK)
$(STATIC_MYPY): $(PYTHON_FILES) $(DEPENDENCIES)
	# Check typing
	@./venv/bin/mypy $(PYTHON_FILES)
	@touch $(STATIC_MYPY)
$(STATIC_PYLINT): $(PYTHON_FILES) $(DEPENDENCIES)
	# Lint
	@./venv/bin/pylint $(PYTHON_FILES)
	@touch $(STATIC_PYLINT)
.PHONY: static-analysis
static-analysis: $(DEPENDENCIES) $(STATIC_PYLINT) $(STATIC_MYPY) $(STATIC_BLACK)
	# Hooray all good

.PHONY: test
test: $(DEPENDENCIES)
	./venv/bin/pytest tests/

.PHONY: test-verbose
test-verbose: $(DEPENDENCIES)
	./venv/bin/pytest  -rP -o log_cli=true --log-cli-level=10 tests/

.PHONY: hooks
hooks:
	@if $(MAKE) -s confirm-hooks ; then \
	     git config -f .gitconfig core.hooksPath .githooks ; \
	     echo 'git config -f .gitconfig core.hooksPath .githooks'; \
	     git config --local include.path ../.gitconfig ; \
	     echo 'git config --local include.path ../.gitconfig' ; \
	fi

.PHONY: fix
fix: $(DEPENDENCIES)
	# Enforce style in-place with Black
	@./venv/bin/black $(PYTHON_FILES)

.PHONY: confirm-hooks
confirm-hooks:
	REPLY="" ; \
	printf "⚠ This will configure this repository to use \`core.hooksPath = .githooks\`. You should look at the hooks so you are not surprised by their behavior.\n"; \
	read -p "Are you sure? [y/n] > " -r ; \
	if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
		printf $(_ERROR) "KO" "Stopping" ; \
		exit 1 ; \
	else \
		printf $(_TITLE) "OK" "Continuing" ; \
		exit 0; \
	fi \

.PHONY: clean
clean:
	# Cleaning everything but the `venv`
	rm -rf ./.mypy_cache
	rm -rf ./.pytest_cache
	find tests/ -depth -name '__pycache__' -type d -exec rm -rf {} \;
	find tests/ -name '*.pyc' -a -type f -delete
	# Done

.PHONY: clean-venv
clean-venv:
	rm -rf ./venv
	# Done

