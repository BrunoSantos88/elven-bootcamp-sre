#!/bin/bash
sudo su
curl -sfL https://get.k3s.io | sudo K3S_URL=https://192.168.98.2:6443 K3S_TOKEN=K106f29549ea29c8b547c54daee3529e58646d13d192b6e62eb0d02b276c7783559::server:9ba83f95353bc1fb398cc478efb6e262 sh -
