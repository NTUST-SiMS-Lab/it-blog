DOCKER_USERNAME ?= hsiangjenli
APPLICATION_NAME ?= simslab-it-blog

build:
	hexo clean
	hexo server

docker-build:
	docker build --platform linux/amd64 --tag ${DOCKER_USERNAME}/${APPLICATION_NAME} .

docker-push:
	docker push ${DOCKER_USERNAME}/${APPLICATION_NAME}:$(VERSION)

exec:
	docker run --rm -it -v ${PWD}:/app -w /app -p 4000:4000 ${DOCKER_USERNAME}/${APPLICATION_NAME} bash