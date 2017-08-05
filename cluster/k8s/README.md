# Kubernetes

Kubernetes related manifest to create dlb deployment and service

# Launch

    kubectl create -f dlb-certs.yml
    cat dlb-dp.jsonnet | jsonnet -V name=dlb -V mode=kubernetes -V access=public - | kubectl create -f -
    cat dlb-dp.jsonnet | jsonnet -V name=dlb - | kubectl create -f -
