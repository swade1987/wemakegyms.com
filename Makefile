APP_NAME=wemakegyms

QUAY_REPO=swade1987
QUAY_USERNAME=swade1987
QUAY_PASSWORD?="unknown"

CIRCLE_BUILD_NUM?="unknown"

SERVER_NAME?="unknown"
SERVER_USER?="unknown"

# Construct the image tag.
VERSION=1.1.$(CIRCLE_BUILD_NUM)

# Construct docker image name.
IMAGE = quay.io/$(QUAY_REPO)/$(APP_NAME):$(VERSION)

build:
	docker build \
	--build-arg git_repository=`git config --get remote.origin.url` \
	--build-arg git_branch=`git rev-parse --abbrev-ref HEAD` \
	--build-arg git_commit=`git rev-parse HEAD` \
	--build-arg built_on=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	-t $(IMAGE) .

run:
	docker run -d -p 80:80 $(IMAGE)

login:
	docker login -u $(QUAY_USERNAME) -p $(QUAY_PASSWORD) quay.io

push:
	docker push $(IMAGE)
	docker rmi $(IMAGE)

deploy:
	ssh -o "StrictHostKeyChecking no" $(SERVER_USER)@$(SERVER_NAME).stevenwade.co.uk ' \
	docker rm -fv www.wemakegyms.com && \
	docker run -d \
	--restart=always -p 80 \
	--name www.wemakegyms.com \
	-v /data/ssmtp:/etc/ssmtp:ro \
	-l interlock.hostname=www \
	-l interlock.domain=wemakegyms.com \
	-l interlock.alias_domain.0=wemakegyms.com \
	-v /data/challenges/.well-known/acme-challenge:/var/www/.well-known/acme-challenge:ro \
	$(IMAGE)
	'