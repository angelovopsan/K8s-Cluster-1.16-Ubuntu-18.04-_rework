#!/bin/bash

echo "##### Started shell provisioning of installHelm.sh #####"; date;
echo "##### Reload bash profile. #####"; date; sudo cp /home/vagrant/.kube/config /root/.kube/; date;
echo "##### Create helm service account. -> kubectl apply -f /vagrant/helm/helm-service-account.yaml #####"; date; kubectl apply -f /vagrant/helm/helm-service-account.yaml; date;
echo "##### wget -q https://get.helm.sh/helm-v2.16.9-linux-amd64.tar.gz #####"; date; wget -q https://get.helm.sh/helm-v2.16.9-linux-amd64.tar.gz; date;
echo "##### tar -zxvf helm-v2.16.9-linux-amd64.tar.gz #####"; date; sudo tar xzvf helm-v2.16.9-linux-amd64.tar.gz; date;                                                                           
echo "##### mv linux-amd64/helm /usr/local/bin/helm #####"; date; sudo mv linux-amd64/helm /usr/local/bin/helm; date;
echo "##### kubectl get pods -n kube-system #####"; date; kubectl get pods -n kube-system; date;
echo "##### helm init #####"; date; helm init --service-account=tiller; date;
echo "##### Wait 30 seconds for Tiller to be deployed #####"; date; sleep 30; date;
echo "##### helm version #####"; date; helm version; date;
echo "##### kubectl get deployment tiller-deploy -n kube-system #####"; date; kubectl get deployment tiller-deploy -n kube-system; date;
echo "Ended shell provisioning of installHelm.sh"; date;
