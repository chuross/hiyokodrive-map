# Carnav Map Tile Repository

カーナビアプリ用の地図タイルとスタイル定義を管理するリポジトリです。

## ディレクトリ構造

- `style.json`: MapLibre用スタイル定義ファイル
- `pmtiles/`: 地図タイルファイル (*.pmtiles) を配置するディレクトリ
  - gitignoreされているため、必要なタイルファイルは手動で配置してください。

## 使い方

### ローカルでの地図編集 (Maputnik)

1. `pmtiles/` 以下に `.pmtiles` ファイルを配置します。
2. Docker環境でサーバーを起動します。

```bash
docker-compose up
```

3. ブラウザで以下のURLにアクセスします。
   - Maputnik (エディタ): `http://localhost:3000`
   - ファイルサーバー: `http://localhost:3001`

4. Maputnikで `style.json` を開くか、新規スタイルを作成して以下の形式でソースを追加します。
   - `pmtiles://http://localhost:3001/YOUR_FILE_NAME.pmtiles`

