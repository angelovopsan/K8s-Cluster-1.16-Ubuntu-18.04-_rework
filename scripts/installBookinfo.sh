#!/bin/bash
kubectl label namespace default istio-injection=enabled;
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.3/samples/bookinfo/platform/kube/bookinfo.yaml;
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.3/samples/bookinfo/networking/bookinfo-gateway.yaml
sleep 60;
# Took 5 min to load Bookinfo
kubectl get all -n default;
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
curl -s http://192.168.223.10:31380/productpage | grep -o "<title>.*</title>"

kubectl apply -f /vagrant/bookinfo/vs/bookinfo-vs_1.yaml
curl -s -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
curl -s -X OPTIONS -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
kubectl apply -f /vagrant/bookinfo/vs/bookinfo-vs_2.yaml
curl -s -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
curl -s -X OPTIONS -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
kubectl apply -f /vagrant/bookinfo/vs/bookinfo-vs_3.yaml
curl -s -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
curl -s -X OPTIONS -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
kubectl apply -f /vagrant/bookinfo/vs/bookinfo-vs_4.yaml
curl -s -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
curl -s -X OPTIONS -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
kubectl apply -f /vagrant/bookinfo/vs/bookinfo-vs_5.yaml
curl -s -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
curl -s -H "Origin: http://testit.com" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
curl -s -X OPTIONS -H "Origin: http://testit.com" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
curl -s -X OPTIONS -H "Origin: http://fake" --verbose http://192.168.223.10:31380/productpage | grep -i "HTTP/1.1 200 OK"
kubectl apply -f /vagrant/bookinfo/vs/bookinfo-vs_6.yaml
kubectl apply -f /vagrant/bookinfo/vs/bookinfo-vs_7.yaml
curl -s -X OPTIONS -H "Origin: fake" -H "Access-Control-Request-Method: GET" --verbose http://192.168.223.10:31380/productpage

# All are passing instead of blocking