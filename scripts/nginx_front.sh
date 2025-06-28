#!/bin/bash
yum update -y
yum install -y nginx amazon-cloudwatch-agent

systemctl enable nginx
systemctl start nginx

echo "Frontend Server" > /usr/share/nginx/html/index.html

# Включаем stub_status
cat <<CONF > /etc/nginx/conf.d/status.conf
server {
  listen 8080;
  location /nginx_status {
    stub_status;
    allow 127.0.0.1;
    deny all;
  }
}
CONF

systemctl restart nginx

# Скрипт для метрик
cat <<'EOM' > /usr/local/bin/push_nginx_metrics.sh
#!/bin/bash
STATE_FILE="/tmp/previous_requests"
status=$(curl -s http://127.0.0.1:8080/nginx_status)
current=$(echo "$status" | sed -n '3p' | awk '{print $3}')

if ! [[ "$current" =~ ^[0-9]+$ ]]; then
  exit 1
fi

if [ -f "$STATE_FILE" ]; then
  previous=$(cat "$STATE_FILE")
else
  previous=$current
fi

rpm=$((current - previous))
echo "$current" > "$STATE_FILE"

aws cloudwatch put-metric-data --namespace Nginx --metric-name TotalRequests --value "$current" --region ${aws_region}
aws cloudwatch put-metric-data --namespace Nginx --metric-name RequestsPerMinute --value "$rpm" --region ${aws_region}
EOM

chmod +x /usr/local/bin/push_nginx_metrics.sh

# systemd service
cat <<EOM > /etc/systemd/system/nginx-metrics.service
[Unit]
Description=Push Nginx metrics to CloudWatch

[Service]
Type=oneshot
ExecStart=/usr/local/bin/push_nginx_metrics.sh
Restart=on-failure
EOM

# systemd timer
cat <<EOM > /etc/systemd/system/nginx-metrics.timer
[Unit]
Description=Run Nginx metrics push every second

[Timer]
OnBootSec=5
OnUnitActiveSec=1s
Unit=nginx-metrics.service

[Install]
WantedBy=timers.target
EOM

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable nginx-metrics.timer
systemctl start nginx-metrics.timer

