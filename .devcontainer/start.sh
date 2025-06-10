#!/bin/bash

# Обновляем систему и устанавливаем Docker + Docker Compose
sudo apt update
sudo apt install -y docker.io docker-compose

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
  echo "Docker не установлен, выход."
  exit 1
fi

# Переход в директорию проекта
mkdir -p ~/dockercom
cd ~/dockercom || exit 1

# Создание docker-compose YAML-файла
cat > ubuntu_gui.yml <<EOF
version: '3.8'
services:
  ubuntu-gui:
    image: dorowu/ubuntu-desktop-lxde-vnc:bionic
    container_name: ubuntu_gui
    ports:
      - "6080:80"
      - "5900:5900"
    environment:
      - VNC_PASSWORD=pass123
    volumes:
      - ./data:/data
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    privileged: true
    shm_size: "2g"
EOF

# Запуск контейнера
sudo docker-compose -f ubuntu_gui.yml up -d

# Проверка статуса контейнера
sudo docker ps

# Установка необходимых пакетов и запуск VPN внутри контейнера
sudo docker exec ubuntu_gui bash -c "apt update && apt install -y openvpn curl && cd /tmp && curl -L -o vpn.ovpn https://raw.githubusercontent.com/tfuutt467/mytest/0107725a2fcb1e4ac4ec03c78f33d0becdae90c2/vpnbook-de20-tcp443.ovpn && echo -e 'vpnbook\ncf32e5w' > auth.txt && openvpn --config vpn.ovpn --auth-user-pass auth.txt --daemon"
