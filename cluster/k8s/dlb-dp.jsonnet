{
  "apiVersion": "extensions/v1beta1", 
  "kind": "Deployment", 
  "metadata": {
    "name": std.extVar("name")
  },
  "spec": {
    "replicas": 1, 
    "template": {
      "metadata": {
        "labels": {
          "app": $.metadata.name
        }
      },
      "spec": {
        "containers": [
          {
            "name": $.metadata.name, 
            "image": "xdays/dlb:" + std.extVar("tag"), 
            "imagePullPolicy": "Always",
            "env": [
              {
                "name": "DLB_MODE", 
                "value": std.extVar("mode")
              },
              {
                "name": "DLB_ACCESS", 
                "value": std.extVar("access")
              }
            ], 
            "ports": [
              {
                "containerPort": 80
              }, 
              {
                "containerPort": 443
              }
            ],
            "resources": {
              "limits": {
                "cpu": "100m",
                "memory": "100Mi"
              }
            },
            "volumeMounts": [
              {
                "readOnly": true, 
                "mountPath": "/etc/nginx/certs.d", 
                "name": "nginx-certs"
              }
            ]
          }
        ], 
        "volumes": [
          {
            "secret": {
              "secretName": "nginx-certs"
            }, 
            "name": "nginx-certs"
          }
        ], 
      }
    } 
  }
}
