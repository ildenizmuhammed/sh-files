#!/bin/bash

# SSHD konfigürasyon dosyası
config_file="/etc/ssh/sshd_config"

# Yedek dosya adı
backup_file="/etc/ssh/sshd_config_backup"

# Önce yedek alalım
cp "$config_file" "$backup_file"

# Değişiklikleri yapalım
sed -i 's/#Port 22/Port 5149/' "$config_file"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "$config_file"

# SSH servisini yeniden başlatalım
systemctl restart sshd

echo "Değişiklikler uygulandı. SSH servisi yeniden başlatıldı."
