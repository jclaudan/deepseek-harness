# @deepseek-ai/dsh-web-search-searxg

`SearxgSearchProvider` : un `WebSearchProvider` basé sur l'API de recherche SearXNG (`POST {baseURL}/api`).

## Sélection

`DSH_WEB_SEARCH_PROVIDER=searxg` sélectionne ce fournisseur. La variable d'environnement `SEARXG_BASE_URL` définit l'endpoint de l'instance SearXNG (par défaut `http://127.0.0.1:8080`).