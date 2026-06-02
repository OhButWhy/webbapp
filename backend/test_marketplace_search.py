import requests
import sys

URL = 'http://127.0.0.1:8000/marketplace/search-by-image'
TEST_IMAGE = (
    'https://www.google.com/images/branding/googlelogo/1x/'
    'googlelogo_color_272x92dp.png'
)

payload = {
    'image_url': TEST_IMAGE,
    'query': 'красная футболка'
}

try:
    r = requests.post(URL, json=payload, timeout=15)
    r.raise_for_status()
    data = r.json()
    results = data.get('results') or data.get('data') or []
    print(f'Results count: {len(results)}')
    if not isinstance(results, list):
        print('Unexpected results format')
        sys.exit(2)
    for i, it in enumerate(results[:10], 1):
        print(i, it.get('title'))
        print('  marketplace:', it.get('marketplace'))
        print('  url:', it.get('url'), 'score=', it.get('score'))
    if len(results) > 10:
        print('Warning: more than 10 results returned')
    sys.exit(0)
except Exception as e:
    print('Test failed:', e)
    sys.exit(1)
