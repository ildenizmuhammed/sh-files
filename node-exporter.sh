#!/bin/bash

# Node Exporter 1.9.1 Kurulum Scripti - Debian
# Bu script Node Exporter'i indirir, kurar ve systemd servisi olarak ayarlar

set -e  # Hata durumunda scripti durdur

echo "🚀 Node Exporter 1.9.1 kurulumu baslatiliyor..."

# 1. Gecici dizine git ve dosyayi indir
echo "📥 Node Exporter indiriliyor..."
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz

# 2. Arsivi ac
echo "📦 Arsiv aciliyor..."
tar xvf node_exporter-1.9.1.linux-amd64.tar.gz

# 3. Binary'yi sistem dizinine kopyala
echo "📋 Binary kopyalaniyor..."
sudo cp node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/

# 4. node_exporter kullanicisi olustur
echo "👤 node_exporter kullanicisi olusturuluyor..."
sudo useradd --no-create-home --shell /bin/false node_exporter

# 5. Dosya sahipligini ayarla
echo "🔒 Dosya izinleri ayarlaniyor..."
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# 6. Systemd servis dosyasi olustur
echo "⚙️ Systemd servis dosyasi olusturuluyor..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Documentation=https://github.com/prometheus/node_exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=node_exporter
Group=node_exporter
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/node_exporter \\
  --collector.cpu \\
  --collector.diskstats \\
  --collector.filesystem \\
  --collector.loadavg \\
  --collector.meminfo \\
  --collector.filefd \\
  --collector.netdev \\
  --collector.stat \\
  --collector.netstat \\
  --collector.systemd \\
  --collector.uname \\
  --collector.vmstat \\
  --collector.time \\
  --collector.hwmon \\
  --web.listen-address=:9100 \\
  --web.telemetry-path=/metrics

SyslogIdentifier=node_exporter
Restart=always
RestartSec=5
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
EOF

# 7. Systemd'yi yeniden yukle ve servisi etkinlestir
echo "🔄 Systemd yapilandirmasi yenileniyor..."
sudo systemctl daemon-reload

echo "✅ Servis etkinlestiriliyor..."
sudo systemctl enable node_exporter

echo "🚀 Servis baslatiliyor..."
sudo systemctl start node_exporter

# 8. Servis durumunu kontrol et
echo "🔍 Servis durumu kontrol ediliyor..."
sleep 2
sudo systemctl status node_exporter --no-pager -l

# 9. Port kontrolu
echo ""
echo "🌐 Port kontrolu yapiliyor..."
if netstat -tuln | grep -q ":9100 "; then
    echo "✅ Node Exporter basariyla calisiyor! Port 9100'de dinliyor."
    echo "🔗 Erisim: http://localhost:9100/metrics"
else
    echo "❌ Port 9100'de servis bulunamadi. Lutfen loglari kontrol edin:"
    echo "   sudo journalctl -u node_exporter -f"
fi

# 10. Temizlik
echo "🧹 Gecici dosyalar temizleniyor..."
rm -rf /tmp/node_exporter-1.9.1.linux-amd64*

echo ""
echo "🎉 Node Exporter kurulumu tamamlandi!"
echo ""
echo "   Metrics erisim: curl http://localhost:9100/metrics"
