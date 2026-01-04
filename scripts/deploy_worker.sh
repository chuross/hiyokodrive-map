#!/bin/bash

# =====================================================
# Cloudflare Worker をデプロイするスクリプト
# =====================================================
#
# 前提条件:
#   1. wrangler がインストールされていること
#   2. Cloudflareにログインしていること
#   3. R2バケットが作成されていること
#   4. japan.pmtilesがR2にアップロードされていること

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SERVER_DIR="$PROJECT_ROOT/server"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "  PMTiles Worker デプロイスクリプト"
echo "========================================"

# wranglerがインストールされているか確認
if ! command -v wrangler &> /dev/null; then
    echo -e "${RED}エラー: wranglerがインストールされていません${NC}"
    echo "以下のコマンドでインストールしてください:"
    echo "  npm install -g wrangler"
    exit 1
fi

# 必要なファイルの確認
if [ ! -f "$SERVER_DIR/worker.js" ]; then
    echo -e "${RED}エラー: server/worker.js が見つかりません${NC}"
    exit 1
fi

if [ ! -f "$SERVER_DIR/wrangler.toml" ]; then
    echo -e "${RED}エラー: server/wrangler.toml が見つかりません${NC}"
    exit 1
fi

cd "$SERVER_DIR"

echo ""
echo -e "${GREEN}Workerをデプロイ中...${NC}"

# Workerをデプロイ
wrangler deploy

echo ""
echo -e "${GREEN}✓ デプロイ完了！${NC}"
echo ""
echo -e "${YELLOW}重要: API_KEYを設定してください${NC}"
echo "  wrangler secret put API_KEY"
echo ""
echo "使用例:"
echo "  curl -H 'X-API-Key: your-api-key' https://pmtiles-proxy.<your-subdomain>.workers.dev/japan.pmtiles"
echo ""
echo "または、クエリパラメータで:"
echo "  https://pmtiles-proxy.<your-subdomain>.workers.dev/japan.pmtiles?api_key=your-api-key"
