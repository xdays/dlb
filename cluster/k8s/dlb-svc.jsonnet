{
  "kind": "Service", 
  "spec": {
    "type": "NodePort", 
    "ports": [
      {
        "targetPort": 80, 
        "name": "http", 
        "port": 80
      }, 
      {
        "targetPort": 443, 
        "name": "https", 
        "port": 443
      }
    ], 
    "selector": {
      "app": $.metadata.name
    }
  }, 
  "apiVersion": "v1", 
  "metadata": {
    "name": std.extVar("name")
  }
}
