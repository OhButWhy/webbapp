import logging
import os
import requests
from bs4 import BeautifulSoup
from PIL import Image
from io import BytesIO
import imagehash
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict

try:
    from curl_cffi import requests as curl_requests
except Exception:
    curl_requests = None

try:
    from playwright.sync_api import sync_playwright
except Exception:
    sync_playwright = None

try:
    from playwright_stealth import Stealth
except Exception:
    Stealth = None

# simple module logger
logger = logging.getLogger("marketplace_real")
if not logger.handlers:
    # configure basic handler at INFO level so uvicorn logs capture it
    h = logging.StreamHandler()
    h.setFormatter(logging.Formatter("[marketplace_real] %(levelname)s: %(message)s"))
    logger.addHandler(h)
    logger.setLevel(logging.INFO)


COLOR_KEYWORDS = {
    (0, 0, 0): 'чёрный',
    (255, 255, 255): 'белый',
    (255, 0, 0): 'красный',
    (0, 0, 255): 'синий',
}

WB_HOME_URL = 'https://www.wildberries.ru/'
WB_SEARCH_API_URL = 'https://search.wb.ru/exactmatch/ru/common/v5/search'
WB_SEARCH_HTML_URL = 'https://www.wildberries.ru/catalog/0/search.aspx?search='
WB_IMPERSONATE = os.environ.get('WB_IMPERSONATE', 'chrome120')
WB_PROXY_URL = (
    os.environ.get('WB_PROXY')
    or os.environ.get('MARKETPLACE_PROXY')
    or os.environ.get('HTTPS_PROXY')
    or os.environ.get('HTTP_PROXY')
)


def get_proxy_config() -> dict[str, str] | None:
    if not WB_PROXY_URL:
        return None
    return {'http': WB_PROXY_URL, 'https': WB_PROXY_URL}


def create_http_session():
    if curl_requests is not None:
        try:
            session = curl_requests.Session(impersonate=WB_IMPERSONATE)
            proxy_config = get_proxy_config()
            if proxy_config:
                try:
                    session.proxies = proxy_config
                except Exception:
                    pass
            return session
        except Exception:
            pass
    session = requests.Session()
    proxy_config = get_proxy_config()
    if proxy_config:
        session.proxies.update(proxy_config)
    return session


def warm_wildberries_session(session, headers: dict[str, str]) -> None:
    try:
        session.get(WB_HOME_URL, headers=headers, timeout=10)
    except Exception:
        logger.debug('wildberries warmup failed')


def normalize_wb_thumbnail(value: object) -> str | None:
    if isinstance(value, str) and value:
        if value.startswith('//'):
            return 'https:' + value
        if value.startswith('/'):
            return WB_HOME_URL.rstrip('/') + value
        return value
    return None


def fetch_wildberries_api_candidates(query: str) -> list[dict]:
    headers = {
        'User-Agent': os.environ.get('MARKETPLACE_USER_AGENT', 'Mozilla/5.0'),
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
        'Referer': WB_HOME_URL,
        'X-Requested-With': 'XMLHttpRequest',
    }
    params = {
        'ab_testing': 'false',
        'appType': 1,
        'curr': 'rub',
        'dest': '-1257786',
        'query': query,
        'resultset': 'catalog',
        'sort': 'popular',
        'spp': 24,
        'suppressSpellcheck': 'false',
    }
    session = create_http_session()
    warm_wildberries_session(session, headers)
    try:
        response = session.get(
            WB_SEARCH_API_URL,
            params=params,
            headers=headers,
            timeout=15,
        )
        if getattr(response, 'status_code', None) != 200:
            logger.warning(
                f"WB API returned non-200: {getattr(response, 'status_code', None)} for query={query}"
            )
            return []
        payload = response.json()
        products = (
            payload.get('data', {}).get('products')
            or payload.get('products')
            or []
        )
        items: List[Dict] = []
        for product in products:
            product_id = product.get('id') or product.get('nmId') or product.get('root')
            if not product_id:
                continue
            brand = (product.get('brand') or '').strip()
            name = (product.get('name') or product.get('title') or '').strip()
            title = ' '.join(part for part in [brand, name] if part).strip()
            if not title:
                continue
            items.append(
                {
                    'title': title,
                    'url': f'https://www.wildberries.ru/catalog/{product_id}/detail.aspx',
                    'marketplace': 'Wildberries',
                    'thumbnail': normalize_wb_thumbnail(
                        product.get('image')
                        or product.get('img')
                        or product.get('preview')
                        or product.get('big'),
                    ),
                }
            )
            if len(items) >= 30:
                break
        logger.info(f'parsed {len(items)} WB API candidates for query={query}')
        return items
    except Exception as exc:
        logger.exception(f'WB API fetch failed for query={query}: {exc}')
        return []


def fetch_wildberries_html_candidates(query: str) -> list[dict]:
    headers = {
        'User-Agent': os.environ.get('MARKETPLACE_USER_AGENT', 'Mozilla/5.0'),
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
        'Referer': WB_HOME_URL,
        'X-Requested-With': 'XMLHttpRequest',
    }
    session = create_http_session()
    warm_wildberries_session(session, headers)
    url = WB_SEARCH_HTML_URL + requests.utils.requote_uri(query)
    try:
        response = session.get(url, headers=headers, timeout=15)
        if getattr(response, 'status_code', None) != 200:
            logger.warning(
                f"WB HTML returned non-200: {getattr(response, 'status_code', None)} for query={query}"
            )
            return []
        soup = BeautifulSoup(response.text, 'lxml')
        items: List[Dict] = []
        for anchor in soup.find_all('a', href=True):
            href = anchor['href']
            if '/catalog/' not in href:
                continue
            title = (anchor.get('aria-label') or anchor.get_text() or '').strip()
            img = anchor.find('img')
            thumbnail = None
            if img:
                thumbnail = normalize_wb_thumbnail(
                    img.get('data-src') or img.get('src') or img.get('data-original')
                )
            if href.startswith('/'):
                href = f'https://www.wildberries.ru{href}'
            if not title and img and img.get('alt'):
                title = (img.get('alt') or '').strip()
            if not title:
                continue
            items.append(
                {
                    'title': title,
                    'url': href,
                    'marketplace': 'Wildberries',
                    'thumbnail': thumbnail,
                }
            )
            if len(items) >= 30:
                break
        logger.info(f'parsed {len(items)} WB HTML candidates for query={query}')
        return items
    except Exception as exc:
        logger.exception(f'WB HTML fetch failed for query={query}: {exc}')
        return []


def fetch_wildberries_playwright_candidates(query: str) -> list[dict]:
    if sync_playwright is None:
        logger.info('Playwright is not installed; skipping WB browser fallback')
        return []

    headers = {
        'User-Agent': os.environ.get('MARKETPLACE_USER_AGENT', 'Mozilla/5.0'),
        'Accept-Language': 'ru-RU,ru;q=0.9,en;q=0.8',
    }
    search_url = WB_SEARCH_HTML_URL + requests.utils.requote_uri(query)
    try:
        with sync_playwright() as p:
            proxy_settings = {'server': WB_PROXY_URL} if WB_PROXY_URL else None
            browser = p.chromium.launch(
                headless=True,
                args=['--disable-blink-features=AutomationControlled'],
                proxy=proxy_settings,
            )
            context = browser.new_context(
                user_agent=headers['User-Agent'],
                locale='ru-RU',
                viewport={'width': 1440, 'height': 900},
            )
            page = context.new_page()
            if Stealth is not None:
                try:
                    Stealth(navigator_languages_override=('ru-RU', 'ru'), navigator_platform_override='Win32').apply_stealth_sync(page)
                except Exception:
                    logger.debug('playwright stealth setup failed')
            page.goto(WB_HOME_URL, wait_until='domcontentloaded', timeout=30000)
            page.goto(search_url, wait_until='domcontentloaded', timeout=30000)
            try:
                page.wait_for_load_state('networkidle', timeout=15000)
            except Exception:
                pass
            html = page.content()
            browser.close()
        items = parse_wildberries(html, 'wildberries.ru')
        logger.info(f'parsed {len(items)} WB Playwright candidates for query={query}')
        return items
    except Exception as exc:
        logger.exception(f'WB Playwright fetch failed for query={query}: {exc}')
        return []


def download_image_to_bytes(url: str, timeout: int = 8) -> bytes | None:
    try:
        ua = os.environ.get('MARKETPLACE_USER_AGENT', 'Mozilla/5.0')
        headers = {'User-Agent': ua}
        session = create_http_session()
        r = session.get(url, headers=headers, timeout=timeout)
        r.raise_for_status()
        return r.content
    except Exception:
        logger.debug(f"download_image_to_bytes failed for {url}")
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


def parse_wildberries(html: str, domain_hint: str) -> list[dict]:
    soup = BeautifulSoup(html, 'lxml')
    items: List[Dict] = []
    # Try common Wildberries patterns: links with /catalog/ and image inside
    for a in soup.find_all('a', href=True):
        href = a['href']
        if '/catalog/' not in href:
            continue
        title = a.get('aria-label') or (a.get_text() or '').strip()
        img = a.find('img')
        thumb = None
        if img:
            thumb = img.get('data-src') or img.get('src') or img.get('data-original')
            if thumb and thumb.startswith('//'):
                thumb = 'https:' + thumb
        if href.startswith('/'):
            href = f'https://{domain_hint}{href}'
        if not title and img and img.get('alt'):
            title = img.get('alt')
        if not title:
            continue
        items.append({'title': title.strip(), 'url': href, 'marketplace': 'Wildberries', 'thumbnail': thumb})
        if len(items) >= 30:
            break
    return items


def fetch_marketplace_candidates(query: str) -> list[dict]:
    # WB-only cascade: API first, then HTML search page as fallback.
    # Other marketplaces are intentionally not queried in this version.
    candidates = fetch_wildberries_api_candidates(query)
    if candidates:
        return candidates

    candidates = fetch_wildberries_html_candidates(query)
    if candidates:
        return candidates

    return fetch_wildberries_playwright_candidates(query)


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
        session = create_http_session()
        r = session.get(url, headers=headers, timeout=timeout)
        r.raise_for_status()
        soup = BeautifulSoup(r.text, 'lxml')
        # First try og:image
        meta = soup.find('meta', property='og:image')
        if meta and meta.get('content'):
            img_url = meta.get('content')
            logger.info(f"found og:image for {url}: {img_url}")
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
            logger.info(f"found inline img for {url}: {img_url}")
            return download_image_to_bytes(img_url, timeout=timeout)
    except Exception:
        logger.debug(f"fetch_candidate_thumbnail_bytes failed for {url}")
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
        if cand:
            logger.info(f"stopping query cascade after hit on query={q}")
        for c in cand:
            u = c.get('url')
            if not u or u in seen_urls:
                continue
            seen_urls.add(u)
            all_candidates.append(c)
        if all_candidates:
            break

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
