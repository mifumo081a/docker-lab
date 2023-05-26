YML = docker-compose.yml

setup:
        @make build
        @make up
        @make ps
down:
        docker-compose down
up:
        docker-compose -f ${YML} up -d
build:
        docker-compse -f ${YML} build
ps:
		docker-compose ps