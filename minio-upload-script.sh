#!/bin/bash

# Yapılandırma
MINIO_ALIAS="myminio"
BUCKET_NAME="veri-bucket"
KAYNAK_DOSYA="$1"
HEDEF_KLASOR="$2"

# Kullanım kontrolü
if [ $# -lt 1 ]; then
    echo "Kullanım: $0 <yüklenecek-dosya-veya-klasör> [hedef-klasör]"
    exit 1
fi

# Dosya mı klasör mü kontrol et
if [ -d "$KAYNAK_DOSYA" ]; then
    # Klasör ise
    echo "Klasör yükleniyor: $KAYNAK_DOSYA -> $MINIO_ALIAS/$BUCKET_NAME/$HEDEF_KLASOR"
    mc cp --recursive "$KAYNAK_DOSYA" "$MINIO_ALIAS/$BUCKET_NAME/$HEDEF_KLASOR"
else
    # Dosya ise
    echo "Dosya yükleniyor: $KAYNAK_DOSYA -> $MINIO_ALIAS/$BUCKET_NAME/$HEDEF_KLASOR"
    mc cp "$KAYNAK_DOSYA" "$MINIO_ALIAS/$BUCKET_NAME/$HEDEF_KLASOR"
fi

# Sonuç kontrolü
if [ $? -eq 0 ]; then
    echo "Yükleme başarılı!"
else
    echo "Yükleme sırasında hata oluştu!"
fi
