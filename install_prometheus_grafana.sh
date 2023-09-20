#!/bin/bash
#Purpose : To Install prometheus and Grafana
#Version : v1
#Created Date :  Wed Sep 20 07:05:27 PM IST 2023
#Author : Narendra Kaduru
############### START ###############
sudo apt update -y

sudo useradd --no-create-home --shell /bin/false prometheus
sudo useradd --no-create-home --shell /bin/false node_exporter

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Download prometheus from central repo
echo "Download prometheus from central repo"
cd /opt
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
sudo sha256sum prometheus-2.47.0.linux-amd64.tar.gz
sudo tar -xvzf prometheus-2.47.0.linux-amd64.tar.gz
sudo rm -rf prometheus-2.47.0.linux-amd64.tar.gz


cd /opt/prometheus-2.47.0.linux-amd64
sudo cp /opt/prometheus-2.47.0.linux-amd64/prometheus /usr/local/bin/
sudo cp /opt/prometheus-2.47.0.linux-amd64/promtool /usr/local/bin/


sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool


sudo cp -r /opt/prometheus-2.47.0.linux-amd64/consoles /etc/prometheus
sudo cp -r /opt/prometheus-2.47.0.linux-amd64/console_libraries /etc/prometheus
sudo cp -r /opt/prometheus-2.47.0.linux-amd64/prometheus.yml /etc/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /etc/prometheus/prometheus.yml


prometheus --version
promtool --version

sudo cat /etc/prometheus/prometheus.yml

sudo -u prometheus /usr/local/bin/prometheus \
        --config.file /etc/prometheus/prometheus.yml \
        --storage.tsdb.path /var/lib/prometheus/ \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries
		

sudo cat <<EOL | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload

sudo systemctl start prometheus
sudo systemctl enable prometheus

sudo ufw allow 9090

# Grafana
sudo wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana 
sudo systemctl start grafana-server
sudo systemctl enable grafana-server.service
sudo ufw allow 3000
###############  END  ###############
