# Writing and build commands. See README.md.
HUGO   ?= hugo
LYCHEE ?= lychee
PUBLIC := $(CURDIR)/public

.PHONY: help note essay serve drafts publish build linkcheck todos check

help: ## list commands
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-10s %s\n", $$1, $$2}'

note: ## start a note on its own draft branch: make note T="Title"
	@scripts/new-post.sh notes "$$T"

essay: ## start an essay on its own draft branch: make essay T="Title"
	@scripts/new-post.sh essays "$$T"

serve: ## local preview with drafts and live reload
	$(HUGO) server -D

drafts: ## list draft/* branches and their age
	@scripts/drafts.sh

publish: ## on a draft branch: mark published, squash-merge to main, push
	@scripts/publish.sh

build: ## production build into public/; any warning fails the build
	rm -rf public
	$(HUGO) --gc --minify --panicOnWarning

linkcheck: ## check internal links in public/ (offline)
	$(LYCHEE) --no-progress --offline \
	  --root-dir "$(PUBLIC)" --index-files index.html \
	  --remap '^https://dotsdl\.com/(.*)$$ file://$(PUBLIC)/$$1' \
	  '$(PUBLIC)/**/*.html'

todos: ## warn (never fail) while TODO(David) placeholders remain
	@scripts/check-todos.sh

check: build linkcheck todos ## production build + link check, same as CI
