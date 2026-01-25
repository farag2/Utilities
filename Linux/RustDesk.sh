ufw allow 21114:21119/tcp
ufw allow 8000/tcp
ufw allow 21116/udp
sudo ufw enable

wget https://raw.githubusercontent.com/techahold/rustdeskinstall/master/install.sh
chmod +x install.sh
./install.sh

# https://gitlab.com/sciter-engine/sciter-js-sdk/-/tree/main/bin/windows/x64
