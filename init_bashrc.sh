#/bin/bash

TARGET_USER=$(who am i | awk '{print $1}')
TARGET_HOME=$(eval echo ~$TARGET_USER)

setup_aliases() {
    local bashrc="$TARGET_HOME/.bashrc"
    local aliases=(
        "alias ls='ls --color=auto'"
        "alias ll='ls -l --color=auto'"
        "alias l.='ls -ld .* --color=auto'"
        "alias lh='ls -alths --color=auto'"
        "alias grep='grep --color=auto'"
        "alias egrep='egrep --color=auto'"
        "alias fgrep='fgrep --color=auto'"
    )

    echo "\n[1/4] 配置用户 $TARGET_USER 的别名..."
    for alias_line in "${aliases[@]}"; do
        if ! grep -qF "$alias_line" "$bashrc"; then
            echo "$alias_line" >> "$bashrc"
        fi
    done
    chown $TARGET_USER:$TARGET_USER "$bashrc"
    echo "✅ 别名配置完成，重新登录后生效"
}


setup_aliases
