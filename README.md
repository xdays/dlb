# DLB

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

