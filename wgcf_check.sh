#!/bin/bash

LOG_FILE="/var/log/wgcf_restart.log"

# 检查参数合法性
if [ $# -ne 1 ] || { [ "$1" != "4" ] && [ "$1" != "6" ]; }; then
    echo "用法: $0 <4|6>"
    echo "示例:"
    echo "  $0 4   # 检查 IPv4 连通性"
    echo "  $0 6   # 检查 IPv6 连通性"
    exit 1
fi

# 根据参数设置 ping 命令
ping_command="ping -$1 -c 1 google.com"

# 执行连通性检查
if ! $ping_command &> /dev/null; then
    # 记录重启时间并执行重启
    systemctl restart wg-quick@wgcf && \
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] IPv$1 检查失败，已重启 wg-quick@wgcf 服务" >> "$LOG_FILE"
fi
