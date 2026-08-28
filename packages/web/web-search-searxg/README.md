# @deepseek-ai/dsh-web-search-searxg

English | [中文](README.zh.md)

`SearxgSearchProvider`: a `WebSearchProvider` backed by the SearXNG search API (`POST {baseURL}/api`).

## Selection

`DSH_WEB_SEARCH_PROVIDER=searxg` selects this provider. The `SEARXG_BASE_URL` environment variable sets the SearXNG instance endpoint (defaults to `http://127.0.0.1:8080`).