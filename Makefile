.PHONY: start stop teardown create-project

start:
	bash setup-infra.sh

stop:
	docker compose -f docker-compose.shared.yml stop

teardown:
	docker compose -f docker-compose.shared.yml down -v
	rm -rf data/

create-project:
	@if [ -z "$(NAME)" ]; then echo "Error: NAME parameter is required. Example: make create-project NAME=meu-projeto PREFIX=31"; exit 1; fi
	@if [ -z "$(PREFIX)" ]; then echo "Error: PREFIX parameter is required. Example: make create-project NAME=meu-projeto PREFIX=31"; exit 1; fi
	bash create-new-project.sh $(NAME) $(PREFIX)
