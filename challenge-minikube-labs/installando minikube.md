# install commandos minikube

Documentaçao:https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fdebian+package

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

# commandos minikube

minikube start --nodes 3 --memory 4g --force
minikube start --nodes 3 -p elfoscluster --memory 4g --driver=docker --force

minikube status -p elfocluster