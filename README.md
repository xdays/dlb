# DLB

[![](https://images.microbadger.com/badges/image/xdays/dlb.svg)](http://microbadger.com/images/xdays/dlb "image size") [![](https://images.microbadger.com/badges/version/xdays/dlb.svg)](http://microbadger.com/images/xdays/dlb "image version")

Dynamical Load Balancer based on OpenResty

# Feature

* dynamic upstream
* dynamic ssl cert
* support both swarm and kubernetes

# Build

    docker build -t dlb .

# Run

    docker run -d --name dlb --net host dlb

# Backend

