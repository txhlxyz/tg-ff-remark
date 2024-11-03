#!/bin/bash
# 检查操作系统版本
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
if [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    VERSION=$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release | tr -d '"')
    if [[ "$VERSION" == "6" || "$VERSION" == "7" ]]; then
        echo "不支持el6和el7系列的系统。"
        exit 1
    fi
    PACKAGE_URL="https://github.com/txhlxyz/tg-ff/releases/download/v2.1.4/tg-ff_2.1.4.rpm"  # 替换为你的rpm包地址
    PACKAGE_FORMAT="rpm"
elif [[ "$OS" == *"Debian"* ]] || [[ "$OS" == *"Ubuntu"* ]]; then
    PACKAGE_URL="https://github.com/txhlxyz/tg-ff/releases/download/v2.1.4/tg-ff_2.1.4.deb"  # 替换为你的deb包地址
    PACKAGE_FORMAT="deb"
else
    echo "不支持的操作系统: $OS"
    exit 1
fi
# 下载并安装包
echo "正在下载 $PACKAGE_FORMAT 包..."
curl -L -o package.$PACKAGE_FORMAT $PACKAGE_URL

if [[ "$PACKAGE_FORMAT" == "rpm" ]]; then
    sudo rpm -ivh package.rpm
elif [[ "$PACKAGE_FORMAT" == "deb" ]]; then
    sudo dpkg -i package.deb
    sudo apt-get install -f  # 修复依赖问题
fi

# 创建systemd服务
SERVICE_NAME="tg-ff"  # 替换为你的服务名
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

echo "[Unit]
Description=TG-FF

[Service]
Type=simple
User=root
ExecStart=/usr/bin/tg-ff --daemon
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE

# 重新加载systemd，并启动服务
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
echo "安装完成。"
echo "使用以下命令进行启动和停止"
echo "-----------------------------------------------"
echo "-----启动：sudo systemctl start $SERVICE_NAME------------"
echo "-----停止：sudo systemctl stop $SERVICE_NAME------------"
echo "-----重启：sudo systemctl restart $SERVICE_NAME------------"
echo "-----------------------------------------------"
