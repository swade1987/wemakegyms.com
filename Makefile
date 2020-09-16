#------------------------------------------------------------------
# Project build information
#------------------------------------------------------------------
PROJNAME := wemakegyms

GCR_REPO := eu.gcr.io/swade1987
GCLOUD_SERVICE_KEY ?="unknown"
GCLOUD_SERVICE_EMAIL := circle-ci@swade1987.iam.gserviceaccount.com
GOOGLE_PROJECT_ID := swade1987
GOOGLE_COMPUTE_ZONE := europe-west2-a

CIRCLE_BUILD_NUM ?="unknown"
VERSION := 1.1.$(CIRCLE_BUILD_NUM)
IMAGE := $(GCR_REPO)/$(PROJNAME):$(VERSION)

#------------------------------------------------------------------
# CI targets
#------------------------------------------------------------------

build:
	docker build -t $(IMAGE) .

push-to-gcr: configure-gcloud-cli
	docker tag $(IMAGE)
	gcloud docker -- push $(IMAGE)
	docker rmi $(IMAGE)

configure-gcloud-cli:
	echo '$(GCLOUD_SERVICE_KEY)' | base64 --decode > /tmp/gcloud-service-key.json
	gcloud auth activate-service-account $(GCLOUD_SERVICE_EMAIL) --key-file=/tmp/gcloud-service-key.json
	gcloud --quiet config set project $(GOOGLE_PROJECT_ID)
	gcloud --quiet config set compute/zone $(GOOGLE_COMPUTE_ZONE)