.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint: ## check style with flake8
	flake8 juliet tests

test: ## run tests quickly with the default Python
	py.test

test-all: ## run tests on every Python version with tox
	tox

coverage: ## check code coverage quickly with the default Python
	coverage run --source juliet -m pytest
	coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html

docs: ## generate Sphinx HTML documentation, including API docs
	rm -f docs/juliet.rst
	rm -f docs/modules.rst
	sphinx-apidoc -o docs/ juliet
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: dist ## package and upload a release
	twine upload dist/*

dist: clean ## builds source and wheel package
	python setup.py sdist
	python setup.py bdist_wheel
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	python setup.py install

JL_SHARE = $(shell julia -e 'print(joinpath(Sys.BINDIR, Base.DATAROOTDIR, "julia"))')
CFLAGS   += $(shell $(JL_SHARE)/julia-config.jl --cflags)
CXXFLAGS += $(filter-out -std=gnu99, $(shell $(JL_SHARE)/julia-config.jl --cflags))
LDFLAGS  += $(shell $(JL_SHARE)/julia-config.jl --ldflags)
LDLIBS   += $(shell $(JL_SHARE)/julia-config.jl --ldlibs)

juliaflags:
	@echo " CFLAGS "
	@echo $(CFLAGS)
	@echo " CXXFLAGS "
	@echo $(CXXFLAGS)
	@echo " LDFLAGS "
	@echo $(LDFLAGS)
	@echo " LDFLAGS "
	@echo $(LDLIBS)

compile:
	# sudo apt-get install libboost-all-dev
	# /sbin/ldconfig -p | grep boost_system | cut -d\> -f2
	# -L/usr/lib/x86_64-linux-gnu/
	#cd build/boost_1_68_0 && ./bootstrap.sh --with-libraries=python --with-python=/usr/include/python3.6/
	#cd build/boost_1_68_0 && ./b2 variant=release link=static cxxflags='-fPIC' --prefix=extern/ -d 0 -j8
	/usr/bin/c++ -Dwrapper_EXPORTS -Ibuild/extern/include/boost -I/usr/include/python3.6m $(CXXFLAGS) -o build/wrapper.cpp.o -c juliet/wrapper.cpp
	/usr/bin/c++ -fPIC -shared -Wl,-soname,wrapper.so -o juliet/wrapper.so build/wrapper.cpp.o -Lbuild/extern/lib -Wl,-rpath,build/extern/lib -lboost_python3 -lboost_numpy -lpython3.6m $(LDFLAGS) $(LDLIBS)
