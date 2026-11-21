HUGO ?= hugo

.PHONY: serve build

## serve: local preview with drafts and live reload
serve:
	$(HUGO) server -D

## build: production build into public/, warnings are errors
build:
	rm -rf public
	$(HUGO) --gc --minify --panicOnWarning
