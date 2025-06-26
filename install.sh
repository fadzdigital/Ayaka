#!/bin/bash

# ==============================================================
url_izin='https://raw.githubusercontent.com/fadzdigital/premis/main/permision.txt'

ip_vps=$(curl -s ipinfo.io/ip)

izin=$(curl -s "$url_izin")

if [[ -n "$izin" ]]; then
  found=false
  while IFS= read -r line; do

    nama=$(echo "$line" | awk '{print $2}')
    ipvps=$(echo "$line" | awk '{print $3}')
    tanggal=$(echo "$line" | awk '{print $5}')

    if [[ "$ipvps" == "$ip_vps" ]]; then
      found=true
      echo "Nama VPS: $nama"
      echo "IP VPS: $ipvps"
      echo "Tanggal Kadaluwarsa: $tanggal"

      tanggal_kadaluwarsa=$(date -d "$tanggal" +%Y-%m-%d)
      tanggal_sekarang=$(date +%Y-%m-%d)

      if [[ "$tanggal_sekarang" > "$tanggal_kadaluwarsa" || "$tanggal_sekarang" == "$tanggal_kadaluwarsa" ]]; then
        clear
        echo "VPS telah expired!"
        exit 1
      else
      clear
      echo "VPS masih aktif."
      fi
      break
    fi
  done <<< "$izin"

  if [[ "$found" == false ]]; then
    clear
    echo "IP VPS tidak ditemukan dalam izin.txt"
    exit 1
  fi
else
  echo "Konten izin.txt tidak berhasil didapatkan dari URL"
  exit 1
fi

clear
read -p "Email: " email
read -p "Input Domain: " domain
read -p "Input Nameserver: " nsdomain

#Resolv
echo -e "nameserver 1.1.1.1" >> /etc/resolv.conf

# Memperbaiki Port Default Login SSH
cd /etc/ssh
find . -type f -name "*sshd_config*" -exec sed -i 's|#Port 22|Port 22|g' {} +
echo -e "Port 3303" >> sshd_config
cd
systemctl daemon-reload
systemctl restart ssh
systemctl restart sshd

# Package
apt update
apt install socat -y
apt install jq -y
apt install wget curl -y
apt install binutils -y
apt install dropbear -y
apt install zip -y
apt install unzip -y
apt install certbot -y
apt install gnupg -y
apt install openssl -y
apt install bc -y
apt install lsof -y
apt install htop -y
apt install gzip -y
apt install bzip2 -y
apt install cron -y
apt install lolcat -y
apt install ruby -y
gem install lolcat
apt install gcc -y
apt install clang -y

# Melakukan Pengambilan File Database
wget -O /m.zip "https://github.com/fadzdigital/Navia/releases/download/1.0/fadzvpn.zip"
cd /
yes A | unzip m.zip
rm -f /m.zip

# Melakukan Permision
chmod +x /usr/local/bin/*
chmod +x /usr/local/rere/*
chmod +x /usr/local/xray-new/*
chmod +x /usr/local/xray-old/*
chmod +x /etc/funny/json/*
chmod +x /etc/funny/default/dropbear/*
chmod +x /etc/funny/default/sslh/*
chmod +x /etc/funny/nginx/*
chmod +x /etc/funny/slowdns/*
chmod +x /etc/funny/websocket/*
chmod +x /etc/funny/udp-custom/*

# Memperbaiki Service X-Ray
apt install sudo -y
sudo chown -R root:root /var/log/xray/
chmod -R 750 /var/log/xray/
systemctl daemon-reload
systemctl enable xray-ws xray-hu xray-grpc xray-xhttp
systemctl start xray-ws xray-hu xray-grpc xray-xhttp
systemctl enable udp-custom
systemctl start udp-custom

# Menyimpan Data Email
echo -e "$email" > /etc/funny/.email

# Mengedit Dropbear
cd /etc/init.d
find . -type f -name "*dropbear*" -exec sed -i 's|/etc/default/dropbear|/etc/funny/default/dropbear/dropbear.conf|g' {} +
cd

curl ipinfo.io/org > /root/.isp
curl ipinfo.io/region > /root/.region

# Melakukan Installasi Dropbear Version 2019
apt install dropbear -y
rm -f /usr/sbin/dropbear
apt update && apt install build-essential zlib1g-dev libtommath-dev -y
wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2019.78.tar.bz2
tar -xvjf dropbear-2019.78.tar.bz2
cd dropbear-2019.78
./configure --prefix=/usr --disable-zlib
make && make install
rm -fr /root/dropbear-2019.78.tar.bz2
cd
rm -r dropbear-2019.78
systemctl daemon-reload
systemctl restart dropbear

# Menjalankan SSH WebSocket
systemctl daemon-reload
systemctl enable websocket
systemctl start websocket

# Melakukan Enable Pada SSLH
apt install sslh -y
systemctl daemon-reload
systemctl enable sslh
systemctl start sslh

# Menyalakan Dukungan Video Call, Telefon & Gaming
systemctl daemon-reload
systemctl enable badvpn
systemctl restart badvpn

# Menyimpan Data Domain & NS Domain
echo "$domain" > /etc/xray/domain
echo "$nsdomain" > /etc/funny/slowdns/nsdomain

# Mengganti semua domain & nsdomain
cd /etc/funny/nginx

cd /etc/systemd/system

# Installasi Nginx
port=$(lsof -i:80 | awk '{print $1}')
systemctl stop apache2
systemctl disable apache2
pkill $port

apt install nginx -y

echo -e "include /etc/funny/nginx/fn.conf;" > /etc/nginx/nginx.conf

sed -i "s|dns.com|$nsdomain|" /etc/systemd/system/dnstt.service

systemctl daemon-reload
systemctl restart dnstt

systemctl stop nginx
certbot certonly --standalone --preferred-challenges http --agree-tos --email dindaputri@rerechanstore.eu.org -d $domain 
cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/xray.crt
cp /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/xray.key
cd /etc/xray
chmod 644 /etc/xray/xray.key
chmod 644 /etc/xray/xray.crt

# menyimpan Domain
sed -i "s|server_name fn.com;|server_name $domain;|" /etc/funny/nginx/main.conf
sed -i "s|server_name fn.com;|server_name $domain;|" /etc/funny/nginx/website.conf

wget https://github.com/dharak36/Xray-core/releases/download/v1.0.0/xray.linux.64bit
mv xray.linux.64bit /usr/local/bin/xray
chmod +x /usr/local/bin/xray

cp /usr/local/bin/xray /usr/local/rere/
chmod +x /usr/local/rere/xray

systemctl daemon-reload
systemctl start nginx
systemctl enable quota
systemctl restart quota
systemctl restart cron
clear

hosting="https://raw.githubusercontent.com/UmVyZWNoYW4wMgo/Zm4K/refs/heads/main"
curl https://rclone.org/install.sh | bash
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "https://raw.githubusercontent.com/praiman99/AutoScriptVPN-AIO/Beginner/rclone.conf"
git clone  https://github.com/magnific0/wondershaper.git
cd wondershaper
make install
rm -rf wondershaper
echo > /home/limit
apt install msmtp-mta ca-certificates bsd-mailx -y
cat<<EOF>>/etc/msmtprc
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
account default
host smtp.gmail.com
port 587
auth on
user revolution.become.true@gmail.com
from revolution.become.true@gmail.com
password rmjydsqnwhehcanj  
logfile ~/.msmtp.log
EOF
chown -R www-data:www-data /etc/msmtprc
cd /root
echo -e "PATH=/usr/local/rere:$PATH" >> /root/.bashrc
source /root/.bashrc
echo -e "source /root/.bashrc" >> /root/.profile
clear
echo -e ""
echo -e "Success Install Script On Server"
reboot
