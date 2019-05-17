#This makefile is used by ci-operator

CGO_ENABLED=0
GOOS=linux
CORE_IMAGES=./cmd/bash ./cmd/controller ./cmd/entrypoint ./cmd/gsutil ./cmd/kubeconfigwriter ./cmd/nop ./cmd/webhook
CORE_IMAGES_WITH_GIT=./cmd/creds-init ./cmd/git-init

# Install core images
install: installuidwrapper
	go install $(CORE_IMAGES) $(CORE_IMAGES_WITH_GIT)
.PHONY: install

# Run E2E tests on OpenShift
test-e2e:
	./openshift/e2e-tests-openshift.sh
.PHONY: test-e2e

# Generate Dockerfiles used by ci-operator. The files need to be committed manually.
generate-dockerfiles:
	./openshift/ci-operator/generate-dockerfiles.sh openshift/ci-operator/Dockerfile.in openshift/ci-operator/knative-images $(CORE_IMAGES)
	./openshift/ci-operator/generate-dockerfiles.sh openshift/ci-operator/Dockerfile-git.in openshift/ci-operator/knative-images $(CORE_IMAGES_WITH_GIT)
.PHONY: generate-dockerfiles

# NOTE(chmou): Install uidwraper for launching some binaries with fixed uid
UIDWRAPPER_PATH=./openshift/ci-operator/uidwrapper
installuidwrapper: $(UIDWRAPPER_PATH)
	install -m755 $(UIDWRAPPER_PATH) $(GOPATH)/bin/

# Generates a ci-operator configuration for a specific branch.
generate-ci-config:
	./openshift/ci-operator/generate-ci-config.sh $(BRANCH) > ci-operator-config.yaml
.PHONY: generate-ci-config

# Generate an aggregated knative yaml file with replaced image references
generate-release:
	./openshift/release/generate-release.sh $(RELEASE)
.PHONY: generate-release