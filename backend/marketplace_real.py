import os
import requests
from bs4 import BeautifulSoup
from PIL import Image
from io import BytesIO
import imagehash
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict


COLOR_KEYWORDS = {
    (0, 0, 0): 'чёрный',
    (255, 255, 255): 'белый',
    (255, 0, 0): 'красный',
    (0, 0, 255): 'синий',
}


def download_image_to_bytes(url: str, timeout: int = 8) -> bytes | None:
    try:
        ua = os.environ.get('MARKETPLACE_USER_AGENT', 'Mozilla/5.0')
        headers = {'User-Agent': ua}
        r = requests.get(url, headers=headers, timeout=timeout)
        r.raise_for_status()
        return r.content
    except Exception:
        return None


def extract_dominant_colors(image_bytes: bytes, top_n: int = 3) -> list[str]:
    try:
        img = Image.open(BytesIO(image_bytes)).convert('RGB')
        small = img.resize((150, 150))
        result = small.getcolors(150 * 150)
        if not result:
            return []
        result.sort(reverse=True)
        colors = [c[1] for c in result[:top_n]]
        keywords: List[str] = []
        for rgb in colors:
            nearest = min(
                COLOR_KEYWORDS.keys(),
                key=lambda k: (k[0] - rgb[0]) ** 2
                + (k[1] - rgb[1]) ** 2
                + (k[2] - rgb[2]) ** 2,
            )
            keywords.append(COLOR_KEYWORDS[nearest])
        return list(dict.fromkeys(keywords))
    except Exception:
        return []


def build_queries(caption: str | None, colors: list[str]) -> list[str]:
    base = (caption or '').strip()
    queries: List[str] = []
    if base:
        queries.append(base)
    for color in colors:
        if base:
            queries.append(f"{base} {color}")
        else:
            queries.append(color)
    queries.append('стильная одежда')
    queries.append('модная одежда')
    return list(dict.fromkeys(q for q in queries if q))


def parse_search_results_from_html(html: str, domain_hint: str) -> list[dict]:
    soup = BeautifulSoup(html, 'lxml')
    items: List[Dict] = []
    product_keys = ['catalog', 'product', 'goods', 'item', 'search']
    for a in soup.find_all('a', href=True):
        href = a['href']
        text = (a.get_text() or '').strip()
        if not text:
            continue
        if href.startswith('/'):
            href = f'https://{domain_hint}{href}'
        if domain_hint not in href:
            if any(k in href for k in product_keys):
                pass
            else:
                continue
        items.append({'title': text, 'url': href, 'marketplace': domain_hint})
        if len(items) >= 20:
            break
    return items


def fetch_marketplace_candidates(query: str) -> list[dict]:
    headers = {
        'User-Agent': os.environ.get('MARKETPLACE_USER_AGENT', 'Mozilla/5.0')
    }
    candidates: List[Dict] = []
    try:
        encoded = requests.utils.requote_uri(query)
        wb = 'https://www.wildberries.ru/catalog/0/search.aspx?search='
        oz = 'https://www.ozon.ru/search/?from_global=true&text='
        ya = 'https://market.yandex.ru/search?text='
        endpoints = [
            (wb + encoded, 'wildberries.ru'),
            (oz + encoded, 'ozon.ru'),
            (ya + encoded, 'market.yandex.ru'),
        ]
        for url, domain in endpoints:
            try:
                r = requests.get(url, headers=headers, timeout=6)
                if r.status_code != 200:
                    continue
                parsed = parse_search_results_from_html(r.text, domain)
                for p in parsed:
                    candidates.append(p)
            except Exception:
                continue
    except Exception:
        pass
    return candidates


def simple_score_candidate(candidate: dict, query_tokens: list[str]) -> float:
    title = candidate.get('title', '').lower()
    score = 0.0
    for t in query_tokens:
        if t.lower() in title:
            score += 1.0
    if 'wildberries' in candidate.get('url', ''):
        score += 0.1
    return score


def compute_phash_from_bytes(image_bytes: bytes) -> imagehash.ImageHash | None:
    try:
        img = Image.open(BytesIO(image_bytes)).convert('RGB')
        return imagehash.phash(img)
    except Exception:
        return None


def fetch_candidate_thumbnail_bytes(url: str, timeout: int = 3):
    try:
        ua = os.environ.get('MARKETPLACE_USER_AGENT', 'Mozilla/5.0')
        headers = {'User-Agent': ua}
        r = requests.get(url, headers=headers, timeout=timeout)
        r.raise_for_status()
        soup = BeautifulSoup(r.text, 'lxml')
        # First try og:image
        meta = soup.find('meta', property='og:image')
        if meta and meta.get('content'):
            img_url = meta.get('content')
            return download_image_to_bytes(img_url, timeout=timeout)
        # fallback: first image tag
        img = soup.find('img')
        if img and img.get('src'):
            img_url = img.get('src')
            if img_url.startswith('//'):
                img_url = 'https:' + img_url
            if img_url.startswith('/'):
                from urllib.parse import urljoin

                img_url = urljoin(url, img_url)
            return download_image_to_bytes(img_url, timeout=timeout)
    except Exception:
        return None
    return None


def visual_similarity_score(phash_a, phash_b) -> float:
    try:
        dist = phash_a - phash_b
        max_bits = phash_a.hash.size
        return max(0.0, 1.0 - (dist / float(max_bits)))
    except Exception:
        return 0.0


def real_search_by_image(
    imageUrl: str | None,
    imagePath: str | None,
    query: str | None,
    max_results: int = 10,
) -> list[dict]:
    image_bytes = None
    if imageUrl:
        image_bytes = download_image_to_bytes(imageUrl)
    if not image_bytes and imagePath:
        try:
            with open(imagePath, 'rb') as f:
                image_bytes = f.read()
        except Exception:
            image_bytes = None

    colors = extract_dominant_colors(image_bytes) if image_bytes else []
    queries = build_queries(query, colors)

    all_candidates: List[Dict] = []
    seen_urls = set()
    for q in queries:
        cand = fetch_marketplace_candidates(q)
        for c in cand:
            u = c.get('url')
            if not u or u in seen_urls:
                continue
            seen_urls.add(u)
            all_candidates.append(c)

    tokens = (query or '').split() + colors
    for c in all_candidates:
        c['text_score'] = simple_score_candidate(c, tokens)

    # Prepare visual rerank
    query_phash = None
    if image_bytes:
        query_phash = compute_phash_from_bytes(image_bytes)
    v = os.environ.get('REAL_MARKETPLACE_MAX_CANDIDATES', '20')
    max_candidates = int(v)
    candidates_for_visual = all_candidates[:max_candidates]

    # download thumbnails in parallel
    thumbnail_map: Dict[str, bytes | None] = {}
    with ThreadPoolExecutor(max_workers=6) as ex:
        future_to_cand = {}
        for c in candidates_for_visual:
            f = ex.submit(fetch_candidate_thumbnail_bytes, c.get('url'))
            future_to_cand[f] = c
        for fut in as_completed(future_to_cand):
            cand = future_to_cand[fut]
            try:
                thumbnail_map[cand.get('url')] = fut.result()
            except Exception:
                thumbnail_map[cand.get('url')] = None

    # compute visual scores and combine
    text_scores = [c.get('text_score', 0.0) for c in all_candidates]
    max_text = max(text_scores) if text_scores else 1.0
    alpha = float(os.environ.get('REAL_MARKETPLACE_VISUAL_WEIGHT', '0.7'))

    for c in all_candidates:
        img_bytes = thumbnail_map.get(c.get('url'))
        visual_score = 0.0
        if query_phash and img_bytes:
            ph = compute_phash_from_bytes(img_bytes)
            if ph:
                visual_score = visual_similarity_score(query_phash, ph)
        text_norm = (c.get('text_score', 0.0) / max_text) if max_text else 0.0
        combined = alpha * visual_score + (1.0 - alpha) * text_norm
        c['visual_score'] = round(visual_score, 3)
        c['score'] = round(combined, 3)

    all_candidates.sort(key=lambda x: x.get('score', 0.0), reverse=True)
    return all_candidates[:max_results]
