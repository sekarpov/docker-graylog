init: docker-down-clear docker-pull docker-build docker-up
up: docker-up
down: docker-down

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-build:
	docker-compose build

deploy:
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'rm -rf graylog && mkdir graylog'
	scp -o StrictHostKeyChecking=no -P ${PORT} -r docker deploy@${HOST}:graylog/docker
	scp -o StrictHostKeyChecking=no -P ${PORT} .env deploy@${HOST}:graylog/.env
	scp -o StrictHostKeyChecking=no -P ${PORT} docker-compose-production.yml deploy@${HOST}:graylog/docker-compose-env.yml
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} "cd /home/deploy/graylog && set -o allexport; source .env; set +o allexport && envsubst < docker-compose-env.yml > docker-compose.yml"
	ssh -o StrictHostKeyChecking=no root@${HOST} -p ${PORT} "cd /home/deploy/graylog && rm docker-compose-env.yml"
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd graylog && echo "COMPOSE_PROJECT_NAME=graylog" >> .env'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd graylog && docker-compose down --remove-orphans'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd graylog && docker-compose pull'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd graylog && docker-compose up -d'