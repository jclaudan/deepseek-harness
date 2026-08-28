/**
 * Wire types for the SearXNG search API (`POST {baseURL}/api`). Types
 * only — no runtime code. SearXNG returns a flat `results[]`; each entry
 * carries a URL, optional title, optional `publishedDate`, and a `content`
 * snippet.
 *
 * @module @deepseek-ai/dsh-web-search-searxg/types
 */

/** Request body sent to SearXNG's search endpoint. */
export interface SearxgSearchRequest {
  q: string
  number?: number
}

/** One entry of SearXNG's flat `results[]`. */
export interface SearxgResult {
  url: string
  title?: string | null
  content?: string | null
  publishedDate?: string | null
}

/** SearXNG's search response envelope. */
export interface SearxgSearchResponse {
  results?: SearxgResult[]
}

/** SearXNG's error response envelope (best-effort; fields vary by failure). */
export interface SearxgError {
  error?: string
  message?: string
}
