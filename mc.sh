#!/bin/bash

# 1️⃣ MinIO Client (mc) kurulumu
echo "MinIO Client kuruluyor..."
if ! command -v mc &> /dev/null
then
    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /tmp/mc
    chmod +x /tmp/mc
    sudo mv /tmp/mc /usr/local/bin/
fi

# mc versiyonu kontrol
echo "mc versiyonu:"
mc --version

# 2️⃣ MinIO sunucu alias ekleme (otomatik alias ve sunucu)
ALIAS="myminio"
SERVER="https://clientmc.mildeniz.space/"

echo "Access Key girin: "
read ACCESS_KEY
echo "Secret Key girin: "
read -s SECRET_KEY
echo ""

echo "Alias oluşturuluyor: $ALIAS -> $SERVER"
mc alias set $ALIAS $SERVER $ACCESS_KEY $SECRET_KEY

# 3️⃣ Küçük kullanım kılavuzu
echo ""
echo "------------------------------------------------"
echo "Kucuk kullanim kilavuzu:"
echo "####  ^=^w^b  ^o 1. Dosya Islemleri ####"
echo "Dosya yukle:                     mc cp /path/to/dosya myminio/BUCKET-NAME/"
echo "Klasor yukle:                    mc cp --recursive /path/to/klasor myminio/BUCKET-NAME/"
echo "Dosya indir:                     mc cp myminio/BUCKET-NAME/file.txt /local/path/"

echo ""
echo "####  ^=   2. Bucket Islemleri ####"
echo "Bucket olustur:                  mc mb myminio/BUCKET-NAME"
echo "Bucket sil:                      mc rb myminio/BUCKET-NAME"
echo "Tum bucket'lari listele:         mc ls myminio"
echo "Bucket icerigini listele:        mc ls myminio/BUCKET-NAME/"
echo "Detayli listele:                 mc ls --recursive --human myminio/BUCKET-NAME/"
echo "Dosya hakkinda bilgi:            mc stat myminio/BUCKET-NAME/file.txt"

echo ""
echo "####  ^=^q  3. Paylasim & Erisim ####"
echo "Download link olustur:           mc share download myminio/BUCKET-NAME/file.txt"
echo "Upload link olustur:             mc share upload myminio/BUCKET-NAME/"



