#!/bin/bash

TARGET=${1:-}


docker build \
	-t kvm_access:latest \
	--progress=plain \
	--target ${TARGET:-desktop} \
	--platform linux/amd64 \
	.
