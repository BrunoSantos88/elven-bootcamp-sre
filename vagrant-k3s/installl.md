# instyalll k3s

* -https://docs.k3s.io/quick-start

curl -sfL https://get.k3s.io | sudo bash -


# Checking k3s version.

k3s --version
mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER  ~/.kube/config
echo 'export KUBECONFIG=~/.kube/config'|tee -a ~/.bashrc
source ~/.bashrc

# Saber se esta correto o cluster
kubectl get nodes

# Step 4: Add extra nodes into your k3s kubernetes

Print out the value of K3S_TOKEN is stored on your server node.

#pegar o token e ip, acessar ssh maquina para setar agente.
sudo cat /var/lib/rancher/k3s/server/node-token

curl -sfL https://get.k3s.io | sh -s - server --server https://192.168.98.2:6443 --token 
K106f29549ea29c8b547c54daee3529e58646d13d192b6e62eb0d02b276c7783559::server:9ba83f95353bc1fb398cc478efb6e262