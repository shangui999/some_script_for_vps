#!/bin/bash

# 自动生成随机密码并设置root账户
# 生成的密码将保存在/root/password.txt

# 生成包含大小写字母和数字的12位随机密码（无tr命令版本）
PASSWORD=$(dd if=/dev/urandom bs=12 count=1 2>/dev/null | od -An -tu1 | awk '{
    srand();
    chars="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    len=length(chars);
    s="";
    for(i=1;i<=NF;i++) {
        s = s substr(chars, ($i % len) + 1, 1)
    }
    print substr(s,1,12)
}')

# 设置root密码
echo "root:${PASSWORD}" | chpasswd
if [ $? -eq 0 ]; then
    echo "root密码设置成功" | tee -a /root/init_password.log
    # 将密码写入文件
    echo "Root Password: ${PASSWORD}" > /root/password.txt
    chmod 600 /root/password.txt
    # 打印密码信息
    echo "--------------------------------------"
    echo "新密码已生成，请及时保存以下信息："
    echo "用户名: root"
    echo "密 码: ${PASSWORD}"
    echo "（此密码已保存至/root/password.txt）"
    echo "--------------------------------------"
else
    echo "root密码设置失败" | tee -a /root/init_password.log
    exit 1
fi

# 启用密码登录
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    echo "sshd配置修改成功" >> /root/init_password.log
else
    echo "sshd配置修改失败" >> /root/init_password.log
    exit 1
fi

systemctl restart sshd

