#!/bin/bash

# MySQL/MariaDB Exporter Kurulum Scripti - PRODUCTION READY
# Debian 11 MariaDB Cluster için test edilmiş
# Kullanım: sudo ./mysql_exporter_install.sh

set -e

# Renkli çıktı
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Fonksiyonlar
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
    echo
}

print_success() {
    echo -e "${CYAN}✓${NC} $1"
}

# Root kontrolü
if [[ $EUID -ne 0 ]]; then
   print_error "Bu script root olarak çalıştırılmalıdır!"
   echo "Kullanım: sudo $0"
   exit 1
fi

# Konfigürasyon
EXPORTER_VERSION="0.15.0"
EXPORTER_USER="mysqld_exporter"
EXPORTER_PORT="9104"
MYSQL_USER="exporter"
MYSQL_PASSWORD=""
MYSQL_HOST="localhost"
MYSQL_PORT="3306"

print_header "MySQL/MariaDB Exporter Kurulum Scripti"
echo -e "${CYAN}MariaDB Galera Cluster için optimize edilmiş${NC}"
echo -e "${CYAN}Sunucu: $(hostname) ($(hostname -I | awk '{print $1}'))${NC}"
echo

# Sistem kontrolleri
print_info "Sistem kontrolleri yapılıyor..."

# MariaDB/MySQL varlığı kontrolü
if ! command -v mysql &> /dev/null; then
    print_error "MySQL/MariaDB client bulunamadı!"
    print_info "Önce MariaDB kurulumunu tamamlayın"
    exit 1
fi

# MariaDB servis kontrolü
if ! systemctl is-active --quiet mariadb && ! systemctl is-active --quiet mysql; then
    print_error "MariaDB servisi çalışmıyor!"
    print_info "MariaDB servisini başlatın: systemctl start mariadb"
    exit 1
fi

print_success "Sistem kontrolleri başarılı"

# Şifre alma
echo
print_info "Konfigürasyon ayarları"
while [[ -z "$MYSQL_PASSWORD" ]]; do
    read -s -p "MySQL exporter kullanıcısı için güçlü bir şifre girin (min 8 karakter): " MYSQL_PASSWORD
    echo
    if [[ -z "$MYSQL_PASSWORD" ]]; then
        print_warning "Şifre boş olamaz!"
    elif [[ ${#MYSQL_PASSWORD} -lt 8 ]]; then
        print_warning "Şifre en az 8 karakter olmalıdır!"
        MYSQL_PASSWORD=""
    fi
done

print_success "Exporter şifresi kabul edildi"

# Root şifresi
read -s -p "MySQL/MariaDB root şifresi: " ROOT_PASSWORD
echo

# Root bağlantı testi
if ! mysql -u root -p$ROOT_PASSWORD -e "SELECT 1;" >/dev/null 2>&1; then
    print_error "MySQL root bağlantısı başarısız!"
    print_info "Root şifresini kontrol edin"
    exit 1
fi

print_success "MySQL root bağlantısı başarılı"

# MariaDB versiyon bilgisi
DB_VERSION=$(mysql -u root -p$ROOT_PASSWORD -e "SELECT VERSION();" -s -N 2>/dev/null)
print_info "Veritabanı: $DB_VERSION"

# Galera kontrolü
GALERA_STATUS=$(mysql -u root -p$ROOT_PASSWORD -e "SHOW STATUS LIKE 'wsrep_ready';" -s -N 2>/dev/null | wc -l)
if [[ $GALERA_STATUS -gt 0 ]]; then
    CLUSTER_SIZE=$(mysql -u root -p$ROOT_PASSWORD -e "SHOW STATUS LIKE 'wsrep_cluster_size';" -s -N 2>/dev/null | awk '{print $2}')
    print_success "Galera Cluster tespit edildi (Cluster Size: $CLUSTER_SIZE)"
else
    print_info "Standart MariaDB kurulumu tespit edildi"
fi

echo

# Gerekli paketleri yükle
print_info "Sistem paketleri kontrol ediliyor..."
apt-get update -qq >/dev/null 2>&1
apt-get install -y wget curl tar netcat-openbsd >/dev/null 2>&1
print_success "Sistem paketleri hazır"

# Exporter indirme
print_info "MySQL Exporter indiriliyor..."

TEMP_DIR="/tmp/mysql_exporter_$(date +%s)"
mkdir -p $TEMP_DIR
cd $TEMP_DIR

DOWNLOAD_URL="https://github.com/prometheus/mysqld_exporter/releases/download/v${EXPORTER_VERSION}/mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz"

if wget -q --show-progress --progress=bar:force $DOWNLOAD_URL 2>&1; then
    print_success "İndirme tamamlandı"
else
    print_error "İndirme başarısız!"
    exit 1
fi

# Kurulum
print_info "MySQL Exporter kuruluyor..."
tar xzf mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz
cp mysqld_exporter-${EXPORTER_VERSION}.linux-amd64/mysqld_exporter /usr/local/bin/
chmod +x /usr/local/bin/mysqld_exporter

# Binary test
if /usr/local/bin/mysqld_exporter --version >/dev/null 2>&1; then
    EXPORTER_VER_OUTPUT=$(/usr/local/bin/mysqld_exporter --version 2>&1 | head -1)
    print_success "Binary kurulumu başarılı: $EXPORTER_VER_OUTPUT"
else
    print_error "Binary dosya çalışmıyor!"
    exit 1
fi

# Sistem kullanıcısı
print_info "Sistem kullanıcısı ayarlanıyor..."
if ! id "$EXPORTER_USER" &>/dev/null; then
    useradd --no-create-home --shell /bin/false --system $EXPORTER_USER
    print_success "Kullanıcı '$EXPORTER_USER' oluşturuldu"
else
    print_success "Kullanıcı '$EXPORTER_USER' mevcut"
fi

# MySQL kullanıcısı oluşturma
print_info "MySQL monitoring kullanıcısı oluşturuluyor..."

# Kullanıcı temizliği ve oluşturma
mysql -u root -p$ROOT_PASSWORD << EOF >/dev/null 2>&1
DROP USER IF EXISTS '${MYSQL_USER}'@'localhost';
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
DROP USER IF EXISTS '${MYSQL_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

# Yeni kullanıcı oluştur
mysql -u root -p$ROOT_PASSWORD << EOF
CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
EOF

if [[ $? -eq 0 ]]; then
    print_success "MySQL kullanıcısı oluşturuldu"
else
    print_error "MySQL kullanıcısı oluşturulamadı!"
    exit 1
fi

# İzinleri aşamalı olarak ver
print_info "MySQL izinleri veriliyor..."

# Temel izinler
mysql -u root -p$ROOT_PASSWORD << EOF
GRANT PROCESS ON *.* TO '${MYSQL_USER}'@'localhost';
GRANT REPLICATION CLIENT ON *.* TO '${MYSQL_USER}'@'localhost';  
GRANT SELECT ON *.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

if [[ $? -eq 0 ]]; then
    print_success "Temel izinler verildi"
else
    print_error "Temel izinler verilemedi!"
    exit 1
fi

# Performance Schema izinleri (hata olursa devam et)
mysql -u root -p$ROOT_PASSWORD << EOF >/dev/null 2>&1 || true
GRANT SELECT ON performance_schema.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

print_info "Performance Schema izinleri denendi"

# Kullanıcı bağlantı testi
if mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW STATUS LIKE 'Uptime';" >/dev/null 2>&1; then
    print_success "Exporter kullanıcısı bağlantısı test edildi"
else
    print_error "Exporter kullanıcısı bağlantısı başarısız!"
    exit 1
fi

# Konfigürasyon dosyaları
print_info "Konfigürasyon dosyaları oluşturuluyor..."
mkdir -p /etc/mysqld_exporter

cat > /etc/mysqld_exporter/.my.cnf << EOF
[client]
user=${MYSQL_USER}
password=${MYSQL_PASSWORD}
host=${MYSQL_HOST}
port=${MYSQL_PORT}

[mysql]
connect-timeout=10
EOF

# Güvenli izinler
chown -R $EXPORTER_USER:$EXPORTER_USER /etc/mysqld_exporter
chmod 700 /etc/mysqld_exporter
chmod 600 /etc/mysqld_exporter/.my.cnf
print_success "Konfigürasyon dosyası oluşturuldu"

# Systemd servis dosyası
print_info "Systemd servisi oluşturuluyor..."
cat > /etc/systemd/system/mysqld_exporter.service << EOF
[Unit]
Description=MySQL/MariaDB Exporter for Prometheus
Documentation=https://github.com/prometheus/mysqld_exporter
Wants=network-online.target
After=network-online.target mysqld.service mariadb.service
Requires=mysqld.service mariadb.service

[Service]
Type=simple
User=${EXPORTER_USER}
Group=${EXPORTER_USER}
ExecStart=/usr/local/bin/mysqld_exporter \\
  --config.my-cnf=/etc/mysqld_exporter/.my.cnf \\
  --collect.global_status \\
  --collect.global_variables \\
  --collect.slave_status \\
  --collect.info_schema.innodb_metrics \\
  --collect.info_schema.processlist \\
  --collect.binlog_size \\
  --collect.info_schema.tables \\
  --collect.perf_schema.file_events \\
  --collect.perf_schema.tableiowaits \\
  --web.listen-address=0.0.0.0:${EXPORTER_PORT} \\
  --web.telemetry-path=/metrics \\
  --log.level=info

SyslogIdentifier=mysqld_exporter
Restart=always
RestartSec=10
StartLimitInterval=300
StartLimitBurst=5

# Güvenlik
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/tmp

[Install]
WantedBy=multi-user.target
EOF

print_success "Systemd servis dosyası oluşturuldu"

# Galera monitoring scripti
print_info "Galera monitoring scripti oluşturuluyor..."
cat > /usr/local/bin/galera_check.sh << 'EOF'
#!/bin/bash

# Galera Cluster Health Check Script
MYSQL_CONFIG="/etc/mysqld_exporter/.my.cnf"

if ! mysql --defaults-file=$MYSQL_CONFIG -e "SELECT 1;" &>/dev/null; then
    echo "❌ MySQL bağlantısı başarısız!"
    exit 1
fi

echo "🔍 Galera Cluster Durumu - $(date)"
echo "=================================="

# Galera varlık kontrolü
WSREP_COUNT=$(mysql --defaults-file=$MYSQL_CONFIG -e "SHOW STATUS LIKE 'wsrep_%';" -s 2>/dev/null | wc -l)

if [[ $WSREP_COUNT -eq 0 ]]; then
    echo "ℹ️  Bu sunucuda Galera cluster çalışmıyor"
    echo "📊 Standart MariaDB/MySQL kurulumu"
    exit 0
fi

# Cluster durumu
echo "📊 Cluster Bilgileri:"
mysql --defaults-file=$MYSQL_CONFIG -e "
SELECT 
    'Cluster Size' as Metric,
    VARIABLE_VALUE as Value
FROM INFORMATION_SCHEMA.GLOBAL_STATUS 
WHERE VARIABLE_NAME = 'wsrep_cluster_size'
UNION ALL
SELECT 
    'Cluster Status' as Metric,
    VARIABLE_VALUE as Value
FROM INFORMATION_SCHEMA.GLOBAL_STATUS 
WHERE VARIABLE_NAME = 'wsrep_cluster_status'
UNION ALL
SELECT 
    'Node State' as Metric,
    CASE VARIABLE_VALUE
        WHEN '0' THEN 'Joining'
        WHEN '1' THEN 'Donor/Desynced' 
        WHEN '2' THEN 'Joined'
        WHEN '3' THEN 'Synced ✅'
        WHEN '4' THEN 'Donor'
        ELSE VARIABLE_VALUE
    END as Value
FROM INFORMATION_SCHEMA.GLOBAL_STATUS 
WHERE VARIABLE_NAME = 'wsrep_local_state'
UNION ALL
SELECT 
    'Ready' as Metric,
    CASE VARIABLE_VALUE 
        WHEN 'ON' THEN 'Yes ✅'
        ELSE 'No ❌'
    END as Value
FROM INFORMATION_SCHEMA.GLOBAL_STATUS 
WHERE VARIABLE_NAME = 'wsrep_ready';
" 2>/dev/null

echo ""
echo "⚡ Performans Metrikleri:"
mysql --defaults-file=$MYSQL_CONFIG -e "
SELECT 
    REPLACE(VARIABLE_NAME, 'wsrep_', '') as Metric,
    VARIABLE_VALUE as Value
FROM INFORMATION_SCHEMA.GLOBAL_STATUS 
WHERE VARIABLE_NAME IN (
    'wsrep_local_bf_aborts',
    'wsrep_local_cert_failures', 
    'wsrep_flow_control_paused'
)
ORDER BY VARIABLE_NAME;
" 2>/dev/null

echo ""
echo "🏷️  Node Konfigürasyonu:"
mysql --defaults-file=$MYSQL_CONFIG -e "
SELECT 
    REPLACE(VARIABLE_NAME, 'wsrep_', '') as Setting,
    VARIABLE_VALUE as Value
FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES 
WHERE VARIABLE_NAME IN (
    'wsrep_cluster_name',
    'wsrep_node_name'
)
ORDER BY VARIABLE_NAME;
" 2>/dev/null

echo "=================================="
EOF

chmod +x /usr/local/bin/galera_check.sh
print_success "Galera monitoring scripti oluşturuldu"

# Firewall ayarları
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        print_info "UFW firewall kuralı ekleniyor..."
        ufw allow $EXPORTER_PORT/tcp comment "MySQL Exporter" >/dev/null 2>&1
        print_success "Firewall kuralı eklendi"
    fi
fi

# Servis başlatma
print_info "MySQL Exporter servisi başlatılıyor..."
systemctl daemon-reload
systemctl enable mysqld_exporter >/dev/null 2>&1

# Önceki servis varsa durdur
systemctl stop mysqld_exporter >/dev/null 2>&1 || true
sleep 2

# Servisi başlat
systemctl start mysqld_exporter

# Başlatma bekleme
print_info "Servis başlatılması bekleniyor..."
for i in {1..10}; do
    if systemctl is-active --quiet mysqld_exporter; then
        break
    fi
    echo -n "."
    sleep 1
done
echo

# Servis durumu kontrolü
if systemctl is-active --quiet mysqld_exporter; then
    print_success "MySQL Exporter servisi başarıyla çalışıyor!"
    
    # Port kontrolü
    sleep 2
    if ss -tlnp 2>/dev/null | grep -q ":$EXPORTER_PORT "; then
        print_success "Port $EXPORTER_PORT aktif"
    else
        print_warning "Port durumu belirsiz"
    fi
    
    # Metrics testi
    print_info "Metrics test ediliyor..."
    sleep 3
    
    if curl -s --connect-timeout 10 http://localhost:$EXPORTER_PORT/metrics > /dev/null 2>&1; then
        # Metric sayısı
        METRIC_COUNT=$(curl -s http://localhost:$EXPORTER_PORT/metrics | grep -c "^mysql_" 2>/dev/null || echo "0")
        print_success "Metrics başarıyla alınıyor! ($METRIC_COUNT metrik)"
        
        # Galera metrikleri kontrolü
        GALERA_METRICS=$(curl -s http://localhost:$EXPORTER_PORT/metrics | grep -c "wsrep" 2>/dev/null || echo "0")
        if [[ $GALERA_METRICS -gt 0 ]]; then
            print_success "Galera metrikleri aktif! ($GALERA_METRICS wsrep metriği)"
        else
            print_info "Galera metrikleri bulunamadı (standart kurulum)"
        fi
        
    else
        print_error "Metrics alınamıyor!"
        print_info "Manuel test: curl http://localhost:$EXPORTER_PORT/metrics"
        print_info "Servis logları: journalctl -u mysqld_exporter -n 20"
    fi
    
else
    print_error "MySQL Exporter servisi başlatılamadı!"
    echo
    print_info "Servis durumu:"
    systemctl status mysqld_exporter --no-pager -l
    echo  
    print_info "Son loglar:"
    journalctl -u mysqld_exporter --no-pager -n 15
    exit 1
fi

# Temizlik
cd /
rm -rf $TEMP_DIR
print_info "Geçici dosyalar temizlendi"

# Test çıktıları
echo
print_header "KURULUM TEST SONUÇLARI"

echo "📊 Örnek Metrikler:"
echo "==================="
timeout 10 curl -s http://localhost:$EXPORTER_PORT/metrics 2>/dev/null | grep -E "(mysql_up|mysql_global_status_uptime|mysql_global_status_threads_connected|wsrep_cluster_size)" | head -8
echo "==================="

# Galera test
echo
print_info "🔍 Galera Cluster Kontrolü:"
/usr/local/bin/galera_check.sh 2>/dev/null || echo "Galera cluster aktif değil"

echo
print_header "KURULUM BAŞARILI! 🎉"

# Bilgiler
NODE_IP=$(hostname -I | awk '{print $1}')
NODE_NAME=$(hostname)

echo -e "${CYAN}📍 Sunucu Bilgileri:${NC}"
echo "   Hostname: $NODE_NAME"
echo "   IP Address: $NODE_IP"  
echo "   Port: $EXPORTER_PORT"
echo "   Database: $DB_VERSION"

echo
echo -e "${CYAN}🔗 Erişim Bilgileri:${NC}"
echo "   Metrics URL: http://$NODE_IP:$EXPORTER_PORT/metrics"
echo "   Health Check: http://$NODE_IP:$EXPORTER_PORT"

echo  
echo -e "${CYAN}🛠️  Yönetim Komutları:${NC}"
echo "   Servis durumu: systemctl status mysqld_exporter"
echo "   Servisi durdur: systemctl stop mysqld_exporter"
echo "   Servisi başlat: systemctl start mysqld_exporter"
echo "   Canlı loglar: journalctl -u mysqld_exporter -f"
echo "   Galera kontrolü: /usr/local/bin/galera_check.sh"

echo
echo -e "${CYAN}📈 Prometheus Konfigürasyonu:${NC}"
echo "---"
echo "  - job_name: 'mysql-$NODE_NAME'"
echo "    static_configs:"
echo "      - targets: ['$NODE_IP:$EXPORTER_PORT']"  
echo "    scrape_interval: 15s"
echo "    scrape_timeout: 10s"
echo "---"

echo
echo -e "${CYAN}🎯 Grafana Dashboard Önerileri:${NC}"
echo "   • MySQL Overview (ID: 7362)"
echo "   • MySQL Exporter Dashboard (ID: 6239)"
echo "   • Percona MySQL Dashboard (ID: 12273)"

echo
print_success "MySQL Exporter kurulumu tamamlandı!"
print_info "Diğer cluster node'larında da aynı scripti çalıştırabilirsiniz"
