prun := poetry run -q
black := $(prun) black ./bot

format-check:
	$(black) --check --diff --color

type-check:
	$(prun) mypy ./bot

lint-check:
	$(prun) ruff . --diff

all-check:
	make format-check type-check lint-check

format:
	$(prun) ruff . --fix --exit-zero --silent
	$(black) --quiet

routine:
	make format type-check lint-check

