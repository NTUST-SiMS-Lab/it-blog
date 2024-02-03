DOCKER_USERNAME ?= hsiangjenli
APPLICATION_NAME ?= simslab-it-blog

build:
	hexo clean
	hexo server

docker-build:
	docker build --platform linux/amd64 --no-cache --tag ${DOCKER_USERNAME}/${APPLICATION_NAME} .

docker-push:
	docker push ${DOCKER_USERNAME}/${APPLICATION_NAME}:$(VERSION)

exec:
	# docker run --rm -it -v ${PWD}:/app -w /app -p 4000:4000 ${DOCKER_USERNAME}/${APPLICATION_NAME} bash
	docker run --rm -it \
		-v ${PWD}/source:/app/source  \
		-v ${PWD}/themes:/app/themes  \
		-v ${PWD}/_config.yml:/app/_config.yml  \
		-v ${PWD}/Makefile:/app/Makefile  \
		-p 4000:4000 ${DOCKER_USERNAME}/${APPLICATION_NAME} bash