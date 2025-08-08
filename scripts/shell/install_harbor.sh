#!/bin/bash

# Harbor智能安装脚本
# 功能: 支持首次安装和镜像迁移后的IP自动适配
# 版本: v2.13.0 (aarch64)

set -e  # 遇到错误立即退出

# 检查root权限
[ "$(id -u)" -ne 0 ] && echo "必须使用root运行!" && exit 1

# 配置变量
HARBOR_VER="v2.13.0"
HARBOR_PKG="harbor-offline-installer-aarch64-${HARBOR_VER}.tgz"
DOWNLOAD_URL="https://github.com/wise2c-devops/build-harbor-aarch64/releases/download/${HARBOR_VER}/${HARBOR_PKG}"
HARBOR_DIR="/root/harbor"
DATA_DIR="/data/harbor"
SERVICE_FILE="/etc/systemd/system/harbor.service"

# 自动获取当前主机最佳IP
get_current_ip() {
  local ip=$(ip route get 1 | awk '{print $7}' | head -1)
  [ -z "$ip" ] && ip=$(hostname -I | awk '{print $1}')
  [ -z "$ip" ] && ip=$(curl -s ifconfig.me)
  echo "$ip"
}

# 安装依赖
install_deps() {
  echo "安装依赖: docker compose wget..."
  #if command -v apt &>/dev/null; then
    #apt update && apt install -y docker.io compose wget
  #elif command -v yum &>/dev/null; then
    #yum install -y docker compose wget
    #systemctl enable --now docker
  #else
    #echo "不支持的包管理器!" && exit 1
  #fi
}

# 下载Harbor
download_harbor() {
  if [ ! -f "/root/${HARBOR_PKG}" ]; then
    echo "下载Harbor安装包..."
    wget -P /root "$DOWNLOAD_URL" || {
      echo "下载失败!"; exit 1
    }
  fi
  tar -zxvf "/root/${HARBOR_PKG}" -C /root || {
    echo "解压失败!"; exit 1
  }
}

# 配置Harbor
configure_harbor() {
  local current_ip=$(get_current_ip)
  echo "检测到本机IP: $current_ip"

  cd "$HARBOR_DIR" || exit 1
  
  # 如果是迁移的镜像，保留原有数据但更新配置
  if [ -f "harbor.yml" ]; then
    echo "检测到现有配置，执行迁移适配..."
    sed -i "s/^hostname: .*/hostname: $current_ip/" harbor.yml
    #sed -i "s/^port: .*/port: 1001/" harbor.yml
  else
    echo "生成全新配置..."
    cp harbor.yml.tmpl harbor.yml
    sed -i "s/^hostname: .*/hostname: $current_ip/" harbor.yml
    sed -i '/^http:/,/^$/ s/^ *port: 80$/  port: 1001/' harbor.yml
    sed -i "s|^data_volume: .*|data_volume: $DATA_DIR|" harbor.yml
    # 注释HTTPS配置
    sed -i '/^https:/s/^/#/' harbor.yml
	sed -i '/^ *port: 443/s/^/# /' harbor.yml
    sed -i '/^  certificate:/s/^/#/' harbor.yml
    sed -i '/^  private_key:/s/^/#/' harbor.yml
  fi

  # 确保数据目录存在
  mkdir -p "$DATA_DIR"
  chmod -R 777 "$DATA_DIR"
}

# 创建系统服务
create_service() {
  cat > "$SERVICE_FILE" <<'EOF'
[Unit]
Description=Harbor Service
After=docker.service
Requires=docker.service

[Service]
Type=simple
Restart=on-failure
RestartSec=30
WorkingDirectory=/root/harbor
Environment=PATH=/usr/bin:/bin:/usr/local/bin
# 关键修改：同时设置目录所有者和权限
ExecStartPre=/bin/bash -c 'mkdir -p /data/harbor/{database,secret,registry} && chown -R 999:999 /data/harbor/database && chmod -R 700 /data/harbor/database && chown -R 10000:10000 /data/harbor/{secret,registry}'
ExecStartPre=/bin/bash -c 'rm -rf /root/harbor/common/config/core/app.conf && mkdir -p /root/harbor/common/config/core && touch /root/harbor/common/config/core/app.conf'
ExecStartPre=/bin/bash -c 'chown -R 10000:10000 /root/harbor/common/config'
ExecStart=/usr/bin/docker compose -f /root/harbor/docker-compose.yml up
ExecStop=/usr/bin/docker compose -f /root/harbor/docker-compose.yml down
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

  # 预先创建目录并设置权限（双重保障）
  mkdir -p /data/harbor/{database,secret,registry}
  chown -R 999:999 /data/harbor/database  # PostgreSQL 容器使用 999:999
  chmod -R 700 /data/harbor/database
  chown -R 10000:10000 /data/harbor/{secret,registry}

  systemctl daemon-reload
  systemctl enable harbor
}

# 主流程
main() {
  install_deps
  download_harbor
  configure_harbor
  
  echo "启动Harbor服务..."
  if [ -f "$HARBOR_DIR/docker-compose.yml" ]; then
    # 如果是迁移环境，先清理旧容器
    cd "$HARBOR_DIR" && docker compose down
  fi
  
  # 执行安装
  cd "$HARBOR_DIR" && ./install.sh
  create_service
  systemctl start harbor

  # 输出信息
  local ip=$(get_current_ip)
  echo -e "\n\033[32mHarbor安装完成!\033[0m"
  echo -e "访问地址: \033[34mhttp://${ip}:1001\033[0m"
  echo -e "管理员账号: \033[33madmin\033[0m"
  echo -e "初始密码: \033[31mHarbor12345\033[0m (请及时修改)"
  echo -e "数据目录: \033[35m${DATA_DIR}\033[0m"
}

main "$@"