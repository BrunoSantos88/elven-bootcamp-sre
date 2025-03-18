# install commandos minikube

Documentaçao:https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fdebian+package

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb

# commandos minikube

sudo minikube start --nodes 3 --memory 2g --force
sudo minikube start --nodes 3 -p elfoscluster --memory 2g --driver=podman --force 

sudo usermod -aG docker $USER

sudo usermod -aG podman $USER

minikube status -p elfocluster


# Install kubectl

curl -LO "https://dl.k8s.io/release/v1.27.3/bin/darwin/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client

# Ou

sudo apt update
sudo apt install -y apt-transport-https
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubectl

# Criando Briede em docker

docker network create --driver bridge minikube-bridge