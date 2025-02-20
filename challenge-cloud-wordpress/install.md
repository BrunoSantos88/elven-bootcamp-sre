# Dependencia

1. installar dependencias e verificar Selinux
- Selinux
sudo apt install selinux-utils
- install Nginx 
sudo apt-get install nginx

2. Modificar pasta Nginx

- cd /etc/nginx/conf.d
- nano blog.conf
- mkdir -p /var/www/html/blog
- nano /var/www/html/blog/index.html

* commandos 
sudo nginx -t
sudo systemctl restart nginx

* pasta conf

nano /etc/nginx/nginx.conf


3. Install Dependncia

- telnet
- mysql client

4. intalll php

- sudo apt-get install software-properties-common
- sudo add-apt-repository ppa:ondrej/php
- sudo apt-get update
- sudo apt-get install -y php7.4