# Kubernetes

Kubernetes related manifest to create dlb deployment and service

# Run

    kubectl create -f dlb-certs.yml
    cat dlb-dp.jsonnet | jsonnet -V name=dlb -V mode=kubernetes -V access=public - | kubectl create -f -
    cat dlb-dp.jsonnet | jsonnet -V name=dlb - | kubectl create -f -

# Backend

When create service for application, you need to add annotations to service so that DLB can discover it. Here's an example:

```
{
    "apiVersion": "v1",
    "kind": "Service",
    "metadata": {
        "annotations": {
            "host": "a.example.com",
            "proto": "http",
            "url": "/"
        },
        "name": "nginx"
    },
    "spec": {
        "ports": [
            {
                "port": 80,
                "protocol": "TCP",
                "targetPort": 80
            }
        ],
        "selector": {
            "app": "nginx"
        },
        "type": "ClusterIP"
    }
}
```
