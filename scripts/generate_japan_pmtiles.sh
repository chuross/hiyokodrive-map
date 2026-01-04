#!/bin/bash

# 日本のOpenStreetMapデータをダウンロードしてPMTilesに変換するスクリプト
# 使用ツール: Planetiler (https://github.com/onthegomap/planetiler)

# 作業用ディレクトリの設定 (カレントディレクトリ)
WORKDIR=$(pwd)
OUTPUT_DIR="$WORKDIR/pmtiles"

# 出力ディレクトリが存在しない場合は作成
mkdir -p "$OUTPUT_DIR"

echo "開始: 日本のOSMデータをダウンロードしてPMTilesに変換します..."
echo "出力先: $OUTPUT_DIR/japan.pmtiles"
echo "注意: 初回実行時はデータのダウンロードと変換に時間がかかります (数GBのメモリを使用します)"

# Dockerを使用してPlanetilerを実行
# --download: 必要なデータを自動ダウンロード
# --area=japan: 日本エリアを指定
# --output: 出力ファイルパス (コンテナ内のパス)
docker run -e JAVA_OPTS="-Xmx8g" -v "$WORKDIR":/data ghcr.io/onthegomap/planetiler:latest \
  --download \
  --area=japan \
  --output=/data/pmtiles/japan.pmtiles

if [ $? -eq 0 ]; then
  echo "完了: $OUTPUT_DIR/japan.pmtiles が作成されました。"
else
  echo "エラー: 変換に失敗しました。"
  exit 1
fi
