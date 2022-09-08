PKG_ID := "observium"
PKG_VERSION := "stable"
LOCAL_IMAGE_TAR := "image.tar"
# PKG_ID := $(shell yq e ".id" manifest.yaml)
# PKG_VERSION := $(shell yq e ".version" manifest.yaml)
# TS_FILES := $(shell find ./ -name \*.ts)

# delete the target of a rule if it has changed and its recipe exits with a nonzero exit status
.DELETE_ON_ERROR:

all: verify

verify: $(PKG_ID).s9pk
	embassy-sdk verify s9pk $(PKG_ID).s9pk

install:
	embassy-cli package install $(PKG_ID).s9pk

clean:
	rm -f $(LOCAL_IMAGE_TAR)
	rm -f $(PKG_ID).s9pk
	rm -f scripts/*.js

scripts/embassy.js: $(TS_FILES)
	deno bundle scripts/embassy.ts scripts/embassy.js

image.tar: image
	docker save start9/$(PKG_ID)/main:$(PKG_VERSION) > $(LOCAL_IMAGE_TAR)

image: Dockerfile docker-entrypoint.sh # dependency files needed to run command
	docker buildx build --tag start9/$(PKG_ID)/main:$(PKG_VERSION) \
			--platform=linux/arm64 \
			--load \
			--build-arg SVN_USERNAME=$(SVN_USERNAME) \
			--build-arg SVN_PASSWORD=$(SVN_PASSWORD) \
			.

$(PKG_ID).s9pk: manifest.yaml instructions.md icon.png LICENSE scripts/embassy.js $(LOCAL_IMAGE_TAR)
	embassy-sdk pack
