# Mini SerpApi

A multi-engine search API built with Ruby on Rails 8, inspired by [SerpApi](https://serpapi.com). Returns clean, normalized JSON from multiple search backends with API key authentication, rate limiting, and search history persistence.

[![CI](https://github.com/Usukhbayar418/mini-serpapi/actions/workflows/ci.yml/badge.svg)](https://github.com/Usukhbayar418/mini-serpapi/actions/workflows/ci.yml)
[![Tests](https://github.com/Usukhbayar418/mini-serpapi/actions/workflows/test.yml/badge.svg)](https://github.com/Usukhbayar418/mini-serpapi/actions/workflows/test.yml)
[![Ruby](https://img.shields.io/badge/ruby-3.4.9-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-8.1-red.svg)](https://rubyonrails.org/)

---

## Live Demo

Try it right now from your terminal:

```bash
# Web search via Brave API
curl -H "x-api-key: demo-key-12345" \
  "https://mini-serpapi.onrender.com/api/v1/search?q=openai"

# Image search
curl -H "x-api-key: demo-key-12345" \
  "https://mini-serpapi.onrender.com/api/v1/search?q=mountain&engine=images"

# Your search history
curl -H "x-api-key: demo-key-12345" \
  "https://mini-serpapi.onrender.com/api/v1/history"
```

**Demo API key**: `demo-key-12345` (rate-limited to 30 requests/minute)

>  Free Render tier — first request may take ~50 seconds to wake the container.

---

## Why This Project

I came across SerpApi's remote job posting in early 2026 and wanted
to actually understand what the company does — not by reading the
docs, but by building something in the same shape. I had no plan, so
my first experiment was scraping a few Mongolian news sites with
Nokogiri and seeing what fell out.

That experiment shifted how I think about APIs. I've always wanted
to build products that are useful to people I know, but the gap I
kept hitting was data — information that exists publicly but only as
HTML pages, not as something an app can call. SerpApi was the first
time it clicked for me that someone has to do this work for the rest
of the ecosystem: take messy public information and turn it into a
clean, callable surface. If I can learn to do that well, then anyone
downstream of me who's building something socially useful has a much
easier first step.

The other thing I learned was how much I'd been undervaluing tests.
Before this project I'd been curling every endpoint by hand after
each change. Writing the request specs in this repo was the first
time I could refactor with confidence — change the controller, run
rspec, trust the result.

---

## Features

-  **Multi-backend search** — Brave (web + images), DuckDuckGo HTML, Mongolian news sites
-  **API key authentication** — `X-API-Key` header required on every request
-  **Rate limiting** — 30 requests/minute per API key, via `rack-attack`
-  **Search history** — every request persisted to SQLite, queryable via `/api/v1/history`
-  **Normalized response format** — same shape regardless of backend
-  **Dockerized deployment** — single Dockerfile boots on Render
-  **CI/CD** — RSpec tests, Rubocop, Brakeman security scan, bundler-audit

---

## Tech Stack

| Layer | Choice |
|---|---|
| Language | Ruby 3.4.9 |
| Framework | Rails 8.1 (API mode) |
| Database | SQLite |
| HTTP client | HTTParty |
| HTML parsing | Nokogiri |
| Auth | Custom `before_action` |
| Rate limiting | rack-attack |
| Tests | RSpec |
| CI | GitHub Actions |
| Deployment | Render (Docker) |

---

## API Reference

All endpoints require the `X-API-Key` header.

### `GET /api/v1/search`

| Param | Type | Default | Description |
|---|---|---|---|
| `q` | string | **required** | Search query |
| `engine` | string | `brave` | One of: `brave`, `images`, `duckduckgo`, `google`, `gogo`, `news` |

**Web search:**

```bash
curl -H "x-api-key: demo-key-12345" \
  "https://mini-serpapi.onrender.com/api/v1/search?q=openai"
```

```json
{
  "query": "openai",
  "engine": "brave",
  "total_results": 10,
  "organic_results": [
    {
      "position": 1,
      "title": "OpenAI",
      "link": "https://openai.com/",
      "snippet": "We're building safe and beneficial AGI..."
    }
  ]
}
```

**Image search:**

```bash
curl -H "x-api-key: demo-key-12345" \
  "https://mini-serpapi.onrender.com/api/v1/search?q=mountain&engine=images"
```

```json
{
  "query": "mountain",
  "engine": "images",
  "total_results": 10,
  "image_results": [
    {
      "position": 1,
      "title": "Mountain landscape",
      "image": "https://images.pexels.com/.../full-res.jpg",
      "thumbnail": "https://imgs.search.brave.com/.../thumb.jpg",
      "source_page": "https://www.pexels.com/search/mountains/",
      "source": "pexels.com",
      "width": 500,
      "height": 667
    }
  ]
}
```

### `GET /api/v1/history`

Returns the caller's most recent searches.

| Param | Type | Default | Description |
|---|---|---|---|
| `limit` | int | `20` | Max records (capped at 100) |

```bash
curl -H "x-api-key: demo-key-12345" \
  "https://mini-serpapi.onrender.com/api/v1/history?limit=5"
```

```json
{
  "count": 5,
  "history": [
    {
      "id": 12,
      "query": "openai",
      "engine": "brave",
      "results_count": 10,
      "duration_ms": 299,
      "created_at": "2026-05-27T10:37:12.060Z"
    }
  ]
}
```

### Error responses

| Status | Body | When |
|---|---|---|
| `400` | `{"error":"q parameter is required"}` | Missing `q` |
| `400` | `{"error":"engine must be one of: ..."}` | Unknown engine |
| `401` | `{"error":"Unauthorized"}` | Missing or invalid `X-API-Key` |
| `429` | rack-attack response | Rate limit exceeded |

---

## Architecture

```
Client
  │
  ▼
┌────────────────────┐
│   rack-attack      │   ← 429 if rate limit exceeded
└──────────┬─────────┘
           ▼
┌────────────────────────────────────┐
│   ApplicationController             │
│   • authenticate_api_key!           │   ← 401 if missing/invalid key
│   • sets @api_key                   │
└────────────┬───────────────────────┘
             │
       ┌─────┴─────┐
       ▼           ▼
┌────────────┐ ┌────────────┐
│ Search     │ │ History    │
│ Controller │ │ Controller │
└─────┬──────┘ └─────┬──────┘
      │              │
      ▼              ▼
┌────────────┐ ┌──────────────┐
│SearchService│ │SearchHistory │
│  case engine│ │ ActiveRecord │
│  ├ brave    │ └──────┬───────┘
│  ├ images   │        │
│  └ ...      │        ▼
└─────┬──────┘    SQLite
      ▼
External APIs (Brave, DDG, …)
```

### Design decisions

- **Strategy pattern in `SearchService`** — each backend is a private method dispatched via `case @engine`. Adding a new engine = one new method + one new `when` clause.
- **Normalized response shape** — `{ query, engine, total_results, organic_results }` (or `image_results`). Clients never see backend-specific fields.
- **`@api_key` on the controller**, not threaded through the service — keeps `SearchService` testable without coupling it to HTTP request internals.
- **rack-attack + MemoryStore** — works on Render's single-instance free tier. Multi-instance deployments would swap to Redis (see roadmap).
- **SQLite over PostgreSQL** — Rails 8's SQLite improvements make it production-viable for a single-instance app, removing the need to provision a separate DB service.

---

## Local Development

```bash
git clone https://github.com/Usukhbayar418/mini-serpapi.git
cd mini-serpapi

rbenv install 3.4.9    # if you don't have it
bundle install
bin/rails db:prepare

cp .env.example .env   # then edit with your keys
bin/rails server
```

### Required environment variables

| Var | Description |
|---|---|
| `BRAVE_API_KEY` | Get from [brave.com/search/api](https://brave.com/search/api/) — $5/month free credit |
| `API_KEYS` | Comma-separated valid client keys, e.g. `demo-key-12345,test-key-67890` |

### Tests

```bash
bundle exec rspec          # unit + request specs
bundle exec rubocop        # style
bundle exec brakeman       # security scan
bin/bundler-audit          # CVE check on gems
```

---

## Deployment

Deployed on [Render](https://render.com) via Docker. `bin/docker-entrypoint` runs `db:prepare` before the server starts, so a fresh container always boots with a valid schema.

To deploy your own copy:
1. Push to GitHub
2. Create a new Render Web Service pointing at your repo
3. Set env vars: `RAILS_MASTER_KEY`, `BRAVE_API_KEY`, `API_KEYS`
4. Render auto-detects the Dockerfile

---

## Roadmap

- [ ] **PostgreSQL** for production history (SQLite is fine for single instance, but history is lost on redeploy without a persistent disk)
- [ ] **Redis-backed rack-attack** for multi-instance rate limiting
- [ ] **Fallback chain** (Brave → DuckDuckGo) on backend failure, with `_backend` field in response
- [ ] **OpenAPI schema** so the API is self-documenting
- [ ] **More request specs** — currently only `q parameter` validation is covered
- [ ] **Per-key usage dashboard** (`/api/v1/usage`) reading from `SearchHistory`

---

## Author

**Dino** — [github.com/Usukhbayar418](https://github.com/Usukhbayar418)

Built as part of an 8-month journey to become a Junior Fullstack Engineer, inspired by SerpApi's core functionality.