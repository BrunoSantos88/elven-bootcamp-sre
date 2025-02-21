# Criar rancher local via docker

sudo docker run --restart=unless-stopped --privileged -p 81:80 -p -d 443:443 rancher/rancher:latest