#!/bin/bash

# 检查root权限
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[31m请使用 sudo 或 root 用户身份运行本脚本\033[0m"
    exit 1
fi

# 默认端口设置
DEFAULT_PORT=16888

# 获取新端口
read -p "请输入新的SSH端口号 [默认 $DEFAULT_PORT]: " NEW_PORT
NEW_PORT=${NEW_PORT:-$DEFAULT_PORT}

# 验证端口合法性
if ! [[ $NEW_PORT =~ ^[0-9]+$ ]] || [ $NEW_PORT -lt 1024 ] || [ $NEW_PORT -gt 65535 ]; then
    echo -e "\033[31m错误：端口号必须为 1024-65535 之间的数字\033[0m"
    exit 1
fi

# 关键服务端口保护
declare -a PROTECTED_PORTS=(21 22 25 53 80 443 3306 5432)
if [[ " ${PROTECTED_PORTS[@]} " =~ " ${NEW_PORT} " ]]; then
    echo -e "\033[33m警告：端口 $NEW_PORT 是常用服务端口，建议更换！\033[0m"
    exit 1
fi

# 端口占用检查函数
check_port_usage() {
    if command -v ss &> /dev/null; then
        PORT_IN_USE=$(ss -tuln | grep -E ":$NEW_PORT( |$)")
    else
        PORT_IN_USE=$(netstat -tuln | grep -E ":$NEW_PORT( |$)")
    fi

    if [ -n "$PORT_IN_USE" ]; then
        echo -e "\n\033[31m错误：端口 $NEW_PORT 已被以下服务占用：\033[0m"
        if command -v lsof &> /dev/null; then
            lsof -i :$NEW_PORT
        else
            echo "提示：安装 lsof 可查看详细信息 (sudo apt install lsof)"
        fi
        echo -e "\n建议操作："
        echo "1. 执行以下命令查找进程：sudo netstat -tulnp | grep :$NEW_PORT"
        echo "2. 更换其他端口重新运行本脚本"
        exit 1
    fi
}

# 执行端口检查
check_port_usage

# 备份原始配置文件
BACKUP_FILE="/etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)"
cp /etc/ssh/sshd_config "$BACKUP_FILE"
echo -e "\n\033[32m已创建SSH配置备份: $BACKUP_FILE\033[0m"

# 修改SSH端口
sed -i "/^#*Port\s\+.*/c\Port $NEW_PORT" /etc/ssh/sshd_config
echo -e "\033[33m已更新SSH端口至: $NEW_PORT\033[0m"

# 配置fail2ban
F2B_JAIL_FILE="/etc/fail2ban/jail.d/sshd.conf"
cat > $F2B_JAIL_FILE <<EOF
[sshd]
enabled = true
port = $NEW_PORT
filter = sshd
logpath = %(sshd_log)s
maxretry = 3
findtime = 600
bantime = 3600
EOF

echo -e "\033[33m已生成fail2ban配置文件: $F2B_JAIL_FILE\033[0m"

# 检查SSH配置有效性
if ! sshd -t 2>/tmp/sshd_error; then
    echo -e "\n\033[31mSSH配置测试失败：\033[0m"
    cat /tmp/sshd_error
    echo -e "\n正在恢复备份并重启服务..."
    cp "$BACKUP_FILE" /etc/ssh/sshd_config
    systemctl restart sshd
    rm -f /tmp/sshd_error
    exit 1
fi

# 重启服务
systemctl restart sshd
systemctl restart fail2ban

# 显示完成信息
echo -e "\n\033[32m服务配置已完成！\033[0m"
echo "----------------------------------------"
echo "新SSH端口: $NEW_PORT"
echo "fail2ban规则:"
fail2ban-client status sshd | grep -E 'Status|Banned IP list'
echo -e "\n\033[33m重要提示：\033[0m"
echo "1. 请测试新端口连接后再关闭当前会话"
echo "2. 防火墙需开放端口：sudo ufw allow $NEW_PORT"
echo "3. 当前连接保持活动状态，不影响后续操作"
echo "4. 备份文件保留在：$BACKUP_FILE"

