#!/bin/bash
# It took Istio 7 min and 10 sec to boot properly after install
curl -L https://git.io/getLatestIstio  | ISTIO_VERSION=1.3.8 sh -
export PATH="$PATH:/home/vagrant/istio-1.3.8/bin"
istioctl verify-install
cd istio-1.3.8/
ll
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
cd install/kubernetes
ll
kubectl apply -f istio-demo.yaml
kubectl apply -f /vagrant/istio/deployments/istio-telemetry.yaml
kubectl scale deployment grafana --replicas=0 -n istio-system
kubectl scale deployment prometheus --replicas=0 -n istio-system
kubectl get namespaces
kubectl get pods -n istio-system
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.3/samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateway