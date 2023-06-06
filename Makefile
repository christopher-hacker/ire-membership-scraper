SHELL := /bin/bash

# makes the absolute path of the src/ directory of the
# project available to makefiles, so they can use project
# scripts as prerequisites
DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export SRC_DIR := $(DIR)/src

.PHONY: \
	all \
	$(TASKS) \
	setup \
	cleanup-all \
	git-lfs \
	sync-template

# uncomment this if you use the recursive task structure. if
# left commented, the "make" command will just run the installation
# all: $(TASKS)
# TASKS := $(sort $(wildcard tasks/*))
# $(TASKS):
#	$(MAKE) -C $@

# also uncomment this if you're using recursive make task structure
# this will clean up all output files in all tasks
# cleanup-all:
#	find tasks -type f -path "*\output/*" -delete
	# add commands to cleanup any folders 
	
sync-template:
	echo "WARNING: This operation can potentially introduce merge conflicts that require manual resolution. Please review the changes carefully before proceeding."
	read -p "Are you sure you want to continue? (y/n) " confirm

	if [[ $confirm == [Yy] || $confirm == [Yy][Ee][Ss] ]]; then
		git remote add template https://github.com/christopher-hacker/Data-Project-Template
		git fetch --all
		git merge template/main --allow-unrelated-histories
	else
		echo "Merge operation aborted."
	fi

# does all setup necessary for the project
setup: \
	.venv/bin/python \
	.git/hooks/pre-commit \
	os-dependencies.log \
	git-lfs

# install hooks in pre-commit-config
.git/hooks/pre-commit: .pre-commit-config.yaml
	poetry run pre-commit install

# by default, uses git lfs for pretty much any data file
# see .gitattributes for more.
git-lfs:
	git lfs install
	git lfs pull

# os-dependencies.log is a file that contains the output of
# installing a list of packages that I commonly use and want to
# always be installed on my vm
os-dependencies.log: apt.txt
	sudo apt-get install -y $$(cat $<) > $@

# creates a virtual environment
.venv/bin/python: pyproject.toml poetry.toml
	poetry install
