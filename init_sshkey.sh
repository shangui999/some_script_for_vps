#/bin/bash

TARGET_USER=$(who am i | awk '{print $1}')
TARGET_HOME=$(eval echo ~$TARGET_USER)

setup_ssh_key() {
    local ssh_dir="$TARGET_HOME/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"
    local pub_key='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILyJ+TshVr8eOxRmf1PuuG01Lrkiz48jnxfHj2Uktklv'

    echo  "\n配置 $TARGET_USER 的SSH密钥..."
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"
    
    if ! grep -qF "$pub_key" "$auth_keys" 2>/dev/null; then
        echo "$pub_key" >> "$auth_keys"
        color_echo green "✅ 公钥已添加到授权文件"
    else
        echo "⚠️  公钥已存在，跳过添加"
    fi

    chmod 600 "$auth_keys"
    chown -R $TARGET_USER:$TARGET_USER "$ssh_dir"
    echo "🔑 密钥文件权限已设置"
}
setup_ssh_key
