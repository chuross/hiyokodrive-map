# Carnav Map Tile Repository

カーナビアプリ用の地図タイルとスタイル定義を管理するリポジトリです。

## ディレクトリ構造

- `style.json`: MapLibre用スタイル定義ファイル
- `pmtiles/`: 地図タイルファイル (*.pmtiles) を配置するディレクトリ
  - gitignoreされているため、必要なタイルファイルは手動で配置してください。

## 使い方

### ローカルでの地図確認 (Tileserver GL)

1. `pmtiles/` 以下に `.pmtiles` ファイルを配置します。
2. Docker環境でサーバーを起動します。

```bash
docker-compose up
```

3. ブラウザで `http://localhost:3000` にアクセスします。
