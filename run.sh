#!/bin/bash

docker run \
	-p 127.0.0.1:6080:6080 \
	--rm \
	--name kvm_access \
	kvm_access
