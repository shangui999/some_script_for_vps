#/bin/bash

# 设置默认root密码

echo root:x0EjVQOcphwkR0DfTw2r | chpasswd
if [ $? -eq 0 ]; then
    echo "root密码设置成功" >> /root/init_password.log
else
    echo "root密码设置失败" >> /root/init_password.log
fi

# 启用密码登录
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    echo "sshd配置修改成功" >> /root/init_password.log
else
    echo "sshd配置修改失败" >> /root/init_password.log
fi

systemctl restart sshd
