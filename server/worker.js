/**
 * Cloudflare Worker - PMTiles R2 Proxy with API Key Authentication
 * 
 * このWorkerはR2に配置されたPMTilesファイルへのアクセスを
 * API_KEYで検証して中継します。
 */

export default {
    async fetch(request, env) {
        // CORSプリフライトリクエストの処理
        if (request.method === 'OPTIONS') {
            return handleCORS();
        }

        // API_KEYの検証
        const apiKey = request.headers.get('X-API-Key') || new URL(request.url).searchParams.get('api_key');

        if (!apiKey || apiKey !== env.API_KEY) {
            return new Response(JSON.stringify({ error: 'Unauthorized: Invalid or missing API key' }), {
                status: 401,
                headers: {
                    'Content-Type': 'application/json',
                    ...corsHeaders(),
                },
            });
        }

        const url = new URL(request.url);
        let path = url.pathname;

        // パスの正規化（先頭のスラッシュを削除）
        if (path.startsWith('/')) {
            path = path.slice(1);
        }

        // デフォルトでjapan.pmtilesにアクセス
        if (path === '' || path === '/') {
            path = 'japan.pmtiles';
        }

        try {
            // Rangeヘッダーの処理
            let range;
            const rangeHeader = request.headers.get('Range');
            if (rangeHeader) {
                const matches = rangeHeader.match(/^bytes=(\d+)-(\d*)$/);
                if (matches) {
                    const offset = parseInt(matches[1], 10);
                    const length = matches[2] ? parseInt(matches[2], 10) - offset + 1 : undefined;
                    range = { offset, length };
                }
            }

            // 試行するパスのリスト
            // ユーザー報告によると pmtiles-bucket/japan.pmtiles のようにネストされている可能性があるため
            const candidates = [path, `pmtiles-bucket/${path}`];

            let object = null;
            let usedPath = "";

            for (const p of candidates) {
                console.log(`Trying to fetch from R2: ${p}, Range: ${rangeHeader || 'none'}`);
                try {
                    object = await env.R2_BUCKET.get(p, {
                        range,
                        onlyIf: request.headers,
                    });
                    if (object) {
                        usedPath = p;
                        console.log(`Found object at: ${p}`);
                        break;
                    }
                } catch (e) {
                    console.warn(`Failed to fetch ${p}:`, e);
                }
            }

            if (!object) {
                return new Response(JSON.stringify({ error: 'Not Found' }), {
                    status: 404,
                    headers: {
                        'Content-Type': 'application/json',
                        ...corsHeaders(),
                    },
                });
            }

            // レスポンスヘッダーの設定
            const headers = new Headers();
            headers.set('Content-Type', object.httpMetadata?.contentType || 'application/octet-stream');
            headers.set('ETag', object.httpEtag);
            headers.set('Cache-Control', 'public, max-age=86400');
            headers.set('Accept-Ranges', 'bytes');

            // CORSヘッダーを追加
            Object.entries(corsHeaders()).forEach(([key, value]) => {
                headers.set(key, value);
            });

            // Range リクエストの処理
            if (request.headers.get('Range')) {
                const rangeHeader = request.headers.get('Range');
                headers.set('Content-Range', `bytes ${object.range.offset}-${object.range.offset + object.range.length - 1}/${object.size}`);

                return new Response(object.body, {
                    status: 206,
                    headers,
                });
            }

            headers.set('Content-Length', object.size);

            return new Response(object.body, {
                status: 200,
                headers,
            });

        } catch (error) {
            console.error('Error fetching from R2:', error);
            return new Response(JSON.stringify({ error: 'Internal Server Error' }), {
                status: 500,
                headers: {
                    'Content-Type': 'application/json',
                    ...corsHeaders(),
                },
            });
        }
    },
};

function corsHeaders() {
    return {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Range, X-API-Key',
        'Access-Control-Expose-Headers': 'Content-Length, Content-Range, Accept-Ranges',
    };
}

function handleCORS() {
    return new Response(null, {
        status: 204,
        headers: corsHeaders(),
    });
}
