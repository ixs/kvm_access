#!/bin/bash

TARGET=${1:-}

# for podman compatibility specify this as env variable instead of argument
export BUILDKIT_PROGRESS=plain

docker build \
	-t kvm_access:latest \
	--target ${TARGET:-desktop} \
	--platform linux/amd64 \
	.
