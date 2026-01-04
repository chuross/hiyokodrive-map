#!/bin/bash

# 日本のOpenStreetMapデータをダウンロードしてPMTilesに変換するスクリプト
# 使用ツール: Planetiler (https://github.com/onthegomap/planetiler)

# プロジェクトルートディレクトリの取得 (スクリプトの場所から逆算)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_ROOT="$(dirname "$SCRIPT_DIR")"

# ディレクトリ設定
# WORKDIR: 中間ファイルやキャッシュファイルの保存先
WORKDIR="$PROJ_ROOT/.planetiler_cache"
# OUTPUT_DIR: 最終成果物の保存先
OUTPUT_DIR="$PROJ_ROOT/pmtiles"

# ディレクトリ作成
mkdir -p "$WORKDIR"
mkdir -p "$OUTPUT_DIR"

echo "開始: 日本のOSMデータをダウンロードしてPMTilesに変換します..."
echo "プロジェクトルート: $PROJ_ROOT"
echo "作業用ディレクトリ: $WORKDIR"
echo "出力先: $OUTPUT_DIR/japan.pmtiles"

# Dockerを使用してPlanetilerを実行
# -v "$WORKDIR":/data -> 作業用・キャッシュ用
# -v "$OUTPUT_DIR":/output -> 出力用
docker run -e JAVA_OPTS="-Xmx8g" \
  -v "$WORKDIR":/data \
  -v "$OUTPUT_DIR":/output \
  ghcr.io/onthegomap/planetiler:latest \
  --download \
  --area=japan \
  --output=/output/japan.pmtiles

if [ $? -eq 0 ]; then
  echo "完了: $OUTPUT_DIR/japan.pmtiles が作成されました。"
else
  echo "エラー: 変換に失敗しました。"
  exit 1
fi
