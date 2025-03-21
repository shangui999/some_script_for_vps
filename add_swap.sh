#!/bin/bash

# 交互式获取 Swap 大小
echo -n "请输入 Swap 大小 (单位 MB): "
read SWAP_SIZE

# 检查输入是否为正整数
if ! [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]]; then
    echo "无效输入，请输入一个正整数。"
    exit 1
fi

# 交互式获取 Swappiness 值
echo -n "请输入 Swappiness 值 (1-100, 默认 60): "
read SWAPPINESS
SWAPPINESS=${SWAPPINESS:-60}

# 检查 Swappiness 是否在 1-100 之间
if ! [[ "$SWAPPINESS" =~ ^[0-9]+$ ]] || [ "$SWAPPINESS" -lt 1 ] || [ "$SWAPPINESS" -gt 100 ]; then
    echo "无效输入，请输入 1 到 100 之间的整数。"
    exit 1
fi

# 检查是否是 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户或 sudo 运行此脚本。"
    exit 1
fi

# 查找现有的 Swap 文件
EXISTING_SWAP=$(swapon --show=NAME --noheadings)
if [ -n "$EXISTING_SWAP" ]; then
    echo "检测到已有 Swap ($EXISTING_SWAP)，正在删除..."
    swapoff "$EXISTING_SWAP"
    rm -f "$EXISTING_SWAP"
    sed -i "\|$EXISTING_SWAP|d" /etc/fstab
    echo "已删除现有 Swap。"
fi

# 交互式设置 Swap 文件路径
echo -n "请输入新的 Swap 文件路径 (默认: /swapfile): "
read SWAP_FILE
SWAP_FILE=${SWAP_FILE:-/swapfile}

# 创建新的 swap 文件
fallocate -l ${SWAP_SIZE}M "$SWAP_FILE" || dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$SWAP_SIZE
chmod 600 "$SWAP_FILE"
mkswap "$SWAP_FILE"

# 启用 swap
swapon "$SWAP_FILE"

# 配置开机自动挂载
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
fi

# 设置 swappiness
if grep -q "vm.swappiness" /etc/sysctl.conf; then
    sed -i "s/^vm.swappiness=.*/vm.swappiness=$SWAPPINESS/" /etc/sysctl.conf
else
    echo "vm.swappiness=$SWAPPINESS" >> /etc/sysctl.conf
fi
sysctl -p

# 显示 swap 状态
swapon --show
echo "Swap 创建完成，已启用并配置为开机启动，Swappiness 设置为 $SWAPPINESS。"

