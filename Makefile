PKG_LIST=$(shell go list ./...)
PROVIDER_NAME=terraform-provider-nsxv
GIT_TAG=$(shell git describe --always --long --dirty)
LD_FLAGS += " -X main.Version=${GIT_TAG} -X main.ProviderName=${PROVIDER_NAME}"

TPV:=$(shell cd ${GOPATH}/src/github.com/hashicorp/terraform && git describe)

ifndef TERRAFORM_VERSION
TERRAFORM_VERSION=v0.9.5
endif

default: all

all: deps build

ifeq ($(TPV),)
deps: tools terraform-download terraform-checkout
else
ifeq ($(TPV),$(TERRAFORM_VERSION))
deps: tools 
else
deps: tools terraform-checkout
endif
endif

tools:
	go get github.com/go-resty/resty

terraform-download:
	echo "Getting terraform source,..."
	go get -d github.com/hashicorp/terraform

terraform-checkout:
	echo "Checkout terraform version $(TERRAFORM_VERSION)"
	cd ${GOPATH}/src/github.com/hashicorp/terraform && git fetch origin && git checkout ${TERRAFORM_VERSION}

	

build:
	go build -ldflags ${LD_FLAGS} -o $(PROVIDER_NAME) github.com/IBM-tfproviders/terraform-provider-nsxv

testacc:
	@echo "Starting Acceptance Test..."
	TF_ACC=1 go test ./nsx -v $(TESTARGS) -timeout 120m

fmt:
	echo "Running fmt ..."
	go fmt $(PKG_LIST)

clean:
	rm -f $(PROVIDER_NAME)


.PHONY: build deps fmt
