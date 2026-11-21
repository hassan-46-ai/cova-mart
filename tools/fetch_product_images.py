#!/usr/bin/env python3
"""Downloads a real photo for every product in assets/data/catalog.json.

Two sources:
  commons  Wikimedia Commons - NO account, NO key. Works out of the box.
  pexels   Pexels stock photos - nicer, needs a free API key (https://www.pexels.com/api/new/).
           Used automatically when the PEXELS_API_KEY environment variable is set.

    pip install requests pillow
    python3 tools/fetch_product_images.py                 # keyless (Commons)
    PEXELS_API_KEY=xxxx python3 tools/fetch_product_images.py
    python3 tools/fetch_product_images.py --source commons --only p001,p002

Windows PowerShell:   $env:PEXELS_API_KEY="xxxx"; python tools/fetch_product_images.py

* Resumable: existing files are skipped.   * Saved as 600x600 JPEG (centre-cropped).
* REVIEW THE RESULT. Search can pick a wrong item. To fix one, add "p042": "better words"
  to tools/image_overrides.json, delete assets/products/p042.jpg and run again.
  Or simply drop your own 600x600 photo in with the same file name.
* Credits/licences are written to tools/image_credits.csv. Keep it: Commons images carry
  licences (CC-BY etc.) that may require attribution.
"""
import argparse
import csv
import io
import json
import os
import re
import sys
import time
from pathlib import Path

import requests
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
UA = {"User-Agent": "CovaMartImageFetcher/1.0 (product photo downloader; contact: owner@covamart.example)"}


def strip_html(text: str) -> str:
    return re.sub(r"<[^>]+>", "", text or "").strip()


def search_commons(query: str):
    r = requests.get(
        "https://commons.wikimedia.org/w/api.php",
        headers=UA,
        timeout=30,
        params={
            "action": "query", "format": "json", "generator": "search",
            "gsrsearch": f"{query} filetype:bitmap", "gsrnamespace": 6, "gsrlimit": 10,
            "prop": "imageinfo", "iiprop": "url|size|mime|extmetadata", "iiurlwidth": 900,
        },
    )
    pages = sorted(r.json().get("query", {}).get("pages", {}).values(), key=lambda p: p.get("index", 0))
    for page in pages:
        info = (page.get("imageinfo") or [{}])[0]
        if info.get("mime") != "image/jpeg":
            continue
        if min(info.get("width", 0), info.get("height", 0)) < 500:
            continue
        meta = info.get("extmetadata", {})
        who = strip_html(meta.get("Artist", {}).get("value", "")) or "unknown"
        lic = strip_html(meta.get("LicenseShortName", {}).get("value", ""))
        return info.get("thumburl") or info["url"], f"{who} ({lic})", info.get("descriptionurl", "")
    return None


def search_pexels(query: str, key: str):
    while True:
        r = requests.get("https://api.pexels.com/v1/search", headers={"Authorization": key},
                         params={"query": query, "per_page": 1, "orientation": "square"}, timeout=30)
        if r.status_code == 429:
            print("Pexels rate limit - waiting 10 minutes...")
            time.sleep(600)
            continue
        break
    photos = r.json().get("photos", []) if r.ok else []
    if not photos:
        return None
    p = photos[0]
    return p["src"]["large"], p["photographer"], p["url"]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", choices=["commons", "pexels"])
    ap.add_argument("--only", help="comma separated product ids, e.g. p001,p002")
    args = ap.parse_args()

    key = os.environ.get("PEXELS_API_KEY")
    source = args.source or ("pexels" if key else "commons")
    if source == "pexels" and not key:
        sys.exit("Set PEXELS_API_KEY or use --source commons")
    print(f"Source: {source}")

    catalog = json.loads((ROOT / "assets/data/catalog.json").read_text(encoding="utf-8"))
    overrides_file = ROOT / "tools/image_overrides.json"
    overrides = json.loads(overrides_file.read_text()) if overrides_file.exists() else {}
    only = set(args.only.split(",")) if args.only else None
    (ROOT / "assets/products").mkdir(parents=True, exist_ok=True)

    credits, ok, miss = [], 0, []
    for product in catalog["products"]:
        if only and product["id"] not in only:
            continue
        target = ROOT / product["image"]
        if target.exists():
            continue
        default_q = product["nameEn"].lower() if source == "commons" else product["imageQuery"]
        query = overrides.get(product["id"], default_q)
        try:
            found = search_commons(query) if source == "commons" else search_pexels(query, key)
            if not found:
                miss.append(product["id"])
                print(f"[miss] {product['id']} {query}")
                continue
            url, credit, page = found
            data = requests.get(url, headers=UA, timeout=60).content
            img = Image.open(io.BytesIO(data)).convert("RGB")
            side = min(img.size)
            left, top = (img.width - side) // 2, (img.height - side) // 2
            img.crop((left, top, left + side, top + side)).resize((600, 600), Image.LANCZOS).save(target, quality=85)
            credits.append([product["id"], query, credit, page])
            ok += 1
            print(f"[ok]   {product['id']} {query}")
        except Exception as e:  # keep going, one bad item must not stop the run
            miss.append(product["id"])
            print(f"[err]  {product['id']} {query}: {e}")
        time.sleep(1)

    if credits:
        f = ROOT / "tools/image_credits.csv"
        new = not f.exists()
        with f.open("a", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            if new:
                w.writerow(["id", "query", "author_and_licence", "page"])
            w.writerows(credits)
    print(f"\nDone: {ok} downloaded, {len(miss)} missing {miss if miss else ''}")
    if miss:
        print("For the missing ones add better search words to tools/image_overrides.json and run again.")


if __name__ == "__main__":
    main()
