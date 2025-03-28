#/bin/bash

apt install curl sudo -y 
# backup 
cp -f /etc/resolv.conf /etc/resolv.conf.bak
# add dns64
echo -e "nameserver 2a01:4f8:c2c:123f::1\nnameserver 2a00:1098:2c::1\nnameserver 2a01:4f9:c010:3f02::1" > /etc/resolv.conf

# install warp

bash <(curl -fsSL git.io/warp.sh) wg

curl -fsSL git.io/wgcf.sh | sudo bash

wgcf register --accept-tos

wgcf generate

cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf

sed -i '/AllowedIPs/s/, *::\/0//' /etc/wireguard/wgcf.conf

#echo "warp wg installed successfully"
#echo "modify /etc/wireguard/wgcf.conf"

wg-quick up wgcf

grep -qE '^[ ]*precedence[ ]*::ffff:0:0/96[ ]*100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' | sudo tee -a /etc/gai.conf



echo "test and wg-quick down wgcf"
echo "systemctl start --now wg-quick@wgcf"


# /etc/gai.conf
# grep -qE '^[ ]*precedence[ ]*::ffff:0:0/96[ ]*100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' | sudo tee -a /etc/gai.conf
