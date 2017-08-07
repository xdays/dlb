# Swarm

Swarm related manifest to create dlb service

# Run

    docker network create -d overlay dlb
    DLB_CLUSTER_HOST=172.19.0.1 docker stack deploy -c docker-compose.yml dlb

# Backend

When create service for applicaiton, you need to add labels to service and publicsh port so that DLB can discover it. Here's an example:

```
docker service create -l host=a.example.com -l proto=http --name nginx --network dlb_default -p 80 nginx
```
