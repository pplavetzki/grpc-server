ACR    = ${AZURE}
NAME   = ${ACR}.azurecr.io/grpc-server
# TAG    = $(shell git rev-parse HEAD)
TAG    := $(shell date +"%Y%m%d.${GITHUB_RUN_NUMBER}")
IMG    = ${NAME}:${TAG}
LATEST = ${NAME}:latest
SUB = ${SUBSCRIPTION}
ACR_PSWD = ${ACR_PASSWORD}

.PHONY: all
all: build test publish

.PHONY: publish
publish: build-image login push

.PHONY: validation
validation: build test

.PHONY: test
test:
	docker build . -t grpc-server-test:1 --target=testrunner
	docker run --rm grpc-server-test:1
	docker image rm grpc-server-test:1

.PHONY: build
build:
	go build -v -o server

.PHONY: clean
clean:
	rm server

.PHONY: build-image
build-image:
	docker build -t ${IMG} --target=executable .
	docker tag ${IMG} ${LATEST}

.PHONY: set-sub
set-sub:
	az account set --subscription ${SUB}

.PHONY: login
login:
	az acr login --name ${ACR} -u ${ACR} -p ${ACR_PSWD}

.PHONY: push
push:
	docker push ${IMG}
	docker push ${LATEST}
