#!/bin/bash

# =====================================================
# Cloudflare R2 に japan.pmtiles をアップロードするスクリプト
# =====================================================
#
# 前提条件:
#   1. rclone がインストールされていること
#      brew install rclone
#   2. rclone で r2 リモートが設定されていること
#      rclone config
#
# rclone設定手順:
#   1. rclone config → n (新規)
#   2. 名前: r2
#   3. Storage: 5 (Amazon S3 Compliant)
#   4. Provider: 6 (Cloudflare R2)
#   5. Access Key ID: R2 API Tokenから取得
#   6. Secret Access Key: 同上
#   7. Endpoint: https://<ACCOUNT_ID>.r2.cloudflarestorage.com

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PMTILES_DIR="$PROJECT_ROOT/pmtiles"
PMTILES_FILE="$PMTILES_DIR/japan.pmtiles"

# R2バケット名
R2_BUCKET_NAME="${R2_BUCKET_NAME:-pmtiles-bucket}"
# rcloneのリモート名
RCLONE_REMOTE="${RCLONE_REMOTE:-r2}"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  PMTiles R2 アップロードスクリプト"
echo "========================================"

# rcloneがインストールされているか確認
if ! command -v rclone &> /dev/null; then
    echo -e "${RED}エラー: rcloneがインストールされていません${NC}"
    echo "以下のコマンドでインストールしてください:"
    echo "  brew install rclone"
    echo ""
    echo "インストール後、rclone configでR2を設定してください"
    exit 1
fi

# rcloneのリモート設定確認
if ! rclone listremotes | grep -q "^${RCLONE_REMOTE}:$"; then
    echo -e "${RED}エラー: rcloneにリモート '${RCLONE_REMOTE}' が設定されていません${NC}"
    echo ""
    echo "以下のコマンドで設定してください:"
    echo "  rclone config"
    echo ""
    echo "設定手順:"
    echo "  1. n (新規リモート)"
    echo "  2. 名前: r2"
    echo "  3. Storage: 5 (Amazon S3 Compliant)"
    echo "  4. Provider: 6 (Cloudflare R2)"
    echo "  5. Access Key ID: R2 API Tokenから取得"
    echo "  6. Secret Access Key: 同上"
    echo "  7. Endpoint: https://<ACCOUNT_ID>.r2.cloudflarestorage.com"
    exit 1
fi

# PMTilesファイルの存在確認
if [ ! -f "$PMTILES_FILE" ]; then
    echo -e "${RED}エラー: $PMTILES_FILE が見つかりません${NC}"
    echo "先に generate_japan_pmtiles.sh を実行してください"
    exit 1
fi

# ファイルサイズを表示
FILE_SIZE=$(ls -lh "$PMTILES_FILE" | awk '{print $5}')
echo -e "${YELLOW}アップロードファイル:${NC} $PMTILES_FILE"
echo -e "${YELLOW}ファイルサイズ:${NC} $FILE_SIZE"
echo -e "${YELLOW}R2バケット:${NC} $R2_BUCKET_NAME"
echo -e "${YELLOW}rcloneリモート:${NC} $RCLONE_REMOTE"
echo ""

# 確認プロンプト
read -p "アップロードを続行しますか？ (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 0
fi

echo ""
echo -e "${GREEN}R2にアップロード中...${NC}"
echo "(大きなファイルのため、しばらく時間がかかります)"
echo ""

# rcloneでR2にアップロード（進捗表示付き）
rclone copy "$PMTILES_FILE" "${RCLONE_REMOTE}:${R2_BUCKET_NAME}/" \
    --progress \
    --transfers 1 \
    --s3-chunk-size 100M

echo ""
echo -e "${GREEN}✓ アップロード完了！${NC}"
echo ""
echo "次のステップ:"
echo "  1. Workerをデプロイ: ./scripts/deploy_worker.sh"
echo "  2. API_KEYを設定: wrangler secret put API_KEY --name pmtiles-proxy"
