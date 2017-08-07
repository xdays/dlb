# DLB

[![](https://images.microbadger.com/badges/image/xdays/dlb.svg)](http://microbadger.com/images/xdays/dlb "image size") [![](https://images.microbadger.com/badges/version/xdays/dlb.svg)](http://microbadger.com/images/xdays/dlb "image version")

Dynamical Load Balancer based on OpenResty

# Feature

* dynamic upstream based on host and url 
* dynamic ssl cert
* support both swarm mode and kubernetes

# Build

    version=`git rev-parse --short HEAD`
    docker build -t dlb:$version .

# Run

Please refer README for [Kuernetes Cluster](./cluster/k8s/README.md) and [Swarm Mode](./cluster/k8s/README.md) on how to launch DLB.


# Backend

Please refer README for [Kuernetes Cluster](./cluster/k8s/README.md) and [Swarm Mode](./cluster/k8s/README.md) on the backend requirements.

# Metadata

Your need to attach some metadata to your applicaitons:

* annotation for k8s
* label for swarm mode

The available metadata is:

| key | value |
| --- | ----- |
| host | http host you apps serve |
| proto | protocol, https or http |
| url | http url you apps serve |
| rewrite | enable or disable url rewrite, 0 disable or 1 enable |
