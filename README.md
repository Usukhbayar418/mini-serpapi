# 🔍 Mini SerpApi

A multi-engine search API built with Ruby on Rails 8, inspired by [SerpApi](https://serpapi.com). Scrapes search results from multiple engines and returns clean, structured JSON.

## Tech Stack

- **Ruby** 3.2
- **Rails** 8.1.3 (API mode)
- **HTTParty** — HTTP requests
- **Nokogiri** — HTML parsing

## Supported Engines

| Engine | Parameter | Source |
|--------|-----------|--------|
| DuckDuckGo | `engine=duckduckgo` | html.duckduckgo.com |
| Gogo.mn | `engine=gogo` | gogo.mn (Mongolian news) |
| News.mn | `engine=news` | news.mn (Mongolian news) |

## Getting Started

### Installation

```bash
git clone https://github.com/<your-username>/mini-serpapi.git
cd mini-serpapi
bundle install
```

### Run the server

```bash
rails server
```

Server runs on `http://localhost:3000`

---

## API Endpoint

```
GET /api/v1/search
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `q` | ✅ Yes | — | Search query |
| `engine` | ❌ No | `duckduckgo` | Search engine |

### Example Requests

**DuckDuckGo search:**
```
GET /api/v1/search?q=mongolian+food&engine=duckduckgo
```

**Gogo.mn news:**
```
GET /api/v1/search?q=монгол&engine=gogo
```

**News.mn articles:**
```
GET /api/v1/search?q=монгол&engine=news
```

### Example Response

```json
{
  "query": "mongolian food",
  "engine": "duckduckgo",
  "total_results": 10,
  "organic_results": [
    {
      "position": 1,
      "title": "Mongolian cuisine - Wikipedia",
      "link": "https://en.wikipedia.org/wiki/Mongolian_cuisine",
      "snippet": "Mongolian sweets include boortsog, a type of biscuit or cookie..."
    },
    {
      "position": 2,
      "title": "11 Traditional Mongolian Foods to Know",
      "link": "https://meanwhileinmongolia.com/traditional-mongolian-food/",
      "snippet": "From buuz to khorkhog and the Five Snouts in between..."
    }
  ]
}
```

### Error Responses

**Missing query parameter:**
```json
{
  "error": "q parameter is required"
}
```

**Invalid engine:**
```json
{
  "error": "engine must be google or duckduckgo"
}
```

---

## Project Structure

```
mini-serpapi/
├── app/
│   ├── controllers/
│   │   └── api/v1/
│   │       └── search_controller.rb   # Request handling & validation
│   └── services/
│       └── search_service.rb          # Scraping logic for all engines
└── config/
    └── routes.rb                      # API routes
```

## How It Works

```
Request → SearchController → SearchService → Scraper → JSON Response
```

1. `SearchController` validates `q` and `engine` parameters
2. `SearchService` picks the right scraper based on engine
3. Scraper fetches HTML or JSON from the target site
4. Results are parsed and returned as structured JSON

### Engine Details

**DuckDuckGo** — Fetches `html.duckduckgo.com/html/` and parses `.result` elements with Nokogiri.

**Gogo.mn** — Calls the internal REST API at `gogo.mn/cache/news-shinemedee` which returns JSON directly — no HTML parsing needed.

**News.mn** — Uses the WordPress REST API at `news.mn/wp-json/wp/v2/posts` with a `search` query parameter.

---

## Author

**Dino** — [github.com/your-username](https://github.com/your-username)

Built as part of an 8-month journey to become a Junior Fullstack Engineer, inspired by SerpApi's core functionality.