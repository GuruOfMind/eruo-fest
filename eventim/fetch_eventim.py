#!/usr/bin/env python3
"""Fetch upcoming Eventim events for the EuroFest catalog via pyventim.

Uses the *public* `product_groups` API (the private `products` scraper is
unreliable). For each catalog artist we search that artist's name within the
relevant categories and emit each dated product as a raw event. Artist→catalog
resolution + dedupe happen on the Node side (`adapters/eventim.ts`), so here we
just keep the Eventim tour/group title as the artist name.

Usage:
    python fetch_eventim.py --catalog catalog.export.json --out eventim_raw.json \
        --markets GERMANY,AUSTRIA --page-limit 1
"""
import argparse
import json
import logging
import sys
import time

from pyventim import EventimClient, EventimCategory, EventimMarket

# pyventim/scrapling are chatty; keep stderr clean for CI logs.
logging.getLogger().setLevel(logging.ERROR)
for noisy in ("scrapling", "httpx", "root"):
    logging.getLogger(noisy).setLevel(logging.ERROR)

# Eventim market -> (ISO country code, market enum). Add markets as you expand.
MARKETS = {
    "GERMANY": ("DE", EventimMarket.GERMANY),
    "AUSTRIA": ("AT", EventimMarket.AUSTRIA),
    "SWITZERLAND": ("CH", EventimMarket.SWITZERLAND),
    "FRANCE": ("FR", EventimMarket.FRANCE),
    "NETHERLANDS": ("NL", EventimMarket.NETHERLANDS),
    "BELGIUM": ("BE", EventimMarket.BELGIUM),
    "SWEDEN": ("SE", EventimMarket.SWEDEN),
    "DENMARK": ("DK", EventimMarket.DENMARK),
}

MAX_GROUPS_PER_ARTIST = 5


def map_status(raw: str | None) -> str:
    s = (raw or "").lower()
    if "cancel" in s:
        return "cancelled"
    if "sold" in s or "booked" in s:
        return "soldout"
    if "available" in s:
        return "onsale"
    return "announced"


def as_dict(obj):
    if hasattr(obj, "model_dump"):
        try:
            return obj.model_dump()
        except Exception:
            pass
    return obj


def products_to_rows(group: dict, country: str) -> list[dict]:
    rows = []
    name = group.get("name")
    currency = group.get("currency")
    for p in group.get("products") or []:
        le = (p.get("type_attributes") or {}).get("liveEntertainment") or {}
        loc = le.get("location") or {}
        start = le.get("startDate")
        if not start or not name:
            continue
        url = p.get("link") or ""
        if not url:
            u = p.get("url") or {}
            url = f"{u.get('domain', '')}{u.get('path', '')}"
        geo = loc.get("geoLocation") or {}
        rows.append(
            {
                "sourceEventId": str(p.get("product_id") or ""),
                "artistNames": [name],
                "venueName": loc.get("name"),
                "city": loc.get("city"),
                "country": country,
                "startsAt": start,
                "status": map_status(p.get("status") or group.get("status")),
                "ticketUrl": url or None,
                "currency": currency,
                "lat": geo.get("latitude"),
                "lng": geo.get("longitude"),
            }
        )
    return rows


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--catalog", required=True, help="catalog.export.json path")
    ap.add_argument("--out", required=True, help="output raw events JSON path")
    ap.add_argument("--markets", default="GERMANY")
    ap.add_argument("--page-limit", type=int, default=1)
    args = ap.parse_args()

    with open(args.catalog, encoding="utf-8") as f:
        artists = json.load(f)

    markets = [m.strip().upper() for m in args.markets.split(",") if m.strip()]
    rows: list[dict] = []

    for mname in markets:
        if mname not in MARKETS:
            print(f"eventim: unknown market {mname}, skipping", file=sys.stderr)
            continue
        country, market = MARKETS[mname]
        client = EventimClient(market=market)
        for a in artists:
            name = a.get("name")
            if not name:
                continue
            cats = [EventimCategory.CONCERTS]
            if a.get("category") == "comedy":
                cats.append(EventimCategory.THEATRE_AND_SHOWS)
            try:
                groups = list(
                    client.product_groups(
                        categories=cats,
                        search_term=name,
                        page_limit=args.page_limit,
                    )
                )[:MAX_GROUPS_PER_ARTIST]
            except Exception as e:  # noqa: BLE001 — never let one artist abort the run
                print(f"eventim {mname} {name}: {type(e).__name__}", file=sys.stderr)
                continue
            for g in groups:
                rows.extend(products_to_rows(as_dict(g), country))
            time.sleep(0.3)  # be polite

    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(rows, f, ensure_ascii=False)
    print(f"eventim: wrote {len(rows)} raw events to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
