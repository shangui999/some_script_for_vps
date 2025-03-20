#/bin/bash

TARGET_USER=$(who am i | awk '{print $1}')
TARGET_HOME=$(eval echo ~$TARGET_USER)

setup_ssh_key() {
    local ssh_dir="$TARGET_HOME/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"
    local pub_key='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo94gzCc99cERjtsA3+DD2BlnuPgaUmItkhhTQqDxJCn/Vx4UQaFRWvulal5Z97dJzzFCds2wx/wP6vtmf6mtVFODDpvhW8Iz3qEg8230Q+BwyhUOSQmYcFQfqdG4IIb0cznJJO/g5ISKZ9HgK/novon6Tax0nusSp0BxLOLFbf/Kv1ctksKU8BUuDxNSqlIBKgrn58H2efUdLy4WM29gaxF/Kr5ALlQSF4am/CLOyVJhADtucBmYZLzz8rMF9i3gbgpbqz8YcNFS2svb2MKpMuolGxPoQPzg1TwxTzQrbgLcIK4GY773Leoe3ZHq1keV74zwM+Sq70iPg5S74sh27'

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
