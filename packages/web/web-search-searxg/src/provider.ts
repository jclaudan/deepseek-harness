import { WebError } from '@deepseek-ai/dsh-web'
import type {
  WebSearchProvider,
  WebSearchRequest,
  WebSearchResult,
  WebSearchSource,
} from '@deepseek-ai/dsh-web'
import type { SearxgError, SearxgResult, SearxgSearchResponse } from './types.ts'

export const SEARXG_PROVIDER_ID = 'searxg'

export const SEARXG_DEFAULT_BASE_URL = 'http://127.0.0.1:8080'

const USER_AGENT = 'deepseek-harness/0.0.1'

export interface SearxgSearchProviderOptions {
  baseURL: string
}

export function mapSearxgResult(result: SearxgResult): WebSearchSource | undefined {
  if (result.url === undefined || result.url.length === 0) return undefined
  return {
    url: result.url,
    ...result.title != null && result.title.length > 0 ? { title: result.title } : {},
    ...result.content != null ? { snippet: result.content } : {},
    ...result.publishedDate != null && result.publishedDate.length > 0 ? { publishedAt: result.publishedDate } : {},
  }
}

export function mapSearxgResponse(response: SearxgSearchResponse): WebSearchResult {
  const sources = (response.results ?? [])
    .map(mapSearxgResult)
    .filter((source): source is WebSearchSource => source !== undefined)
  return { sources, truncated: false }
}

export class SearxgSearchProvider implements WebSearchProvider {
  readonly id = SEARXG_PROVIDER_ID

  constructor(private readonly options: SearxgSearchProviderOptions) {}

  available(): boolean {
    return isValidBaseUrl(this.options.baseURL)
  }

  async search(request: WebSearchRequest, signal?: AbortSignal): Promise<WebSearchResult> {
    const numResults = request.maxResults ?? 10
    let response: Response
    try {
      response = await fetch(`${this.options.baseURL}/api`, {
        method: 'POST',
        redirect: 'error',
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
          'user-agent': USER_AGENT,
        },
        body: JSON.stringify({
          q: request.query,
          number: numResults,
        }),
        ...signal !== undefined ? { signal } : {},
      })
    } catch (err: unknown) {
      if (isAbortError(err)) throw new WebError('SearXNG search aborted', 'WEB_ABORTED', { cause: err })
      throw new WebError(`SearXNG search request failed: ${String(err)}`, 'WEB_PROVIDER_ERROR', { cause: err })
    }

    if (!response.ok) {
      const status = response.status
      let message = `SearXNG API error (HTTP ${status})`
      try {
        const parsed = await response.json() as SearxgError
        const detail = parsed.error ?? parsed.message
        if (detail !== undefined && detail.length > 0) message = detail
      } catch (error: unknown) {
        if (isAbortError(error)) throw new WebError('SearXNG search aborted', 'WEB_ABORTED', { cause: error })
      }
      throw new WebError(message, 'WEB_PROVIDER_ERROR')
    }

    try {
      const payload = await response.json() as SearxgSearchResponse
      return mapSearxgResponse(payload)
    } catch (err: unknown) {
      if (isAbortError(err)) throw new WebError('SearXNG search aborted', 'WEB_ABORTED', { cause: err })
      throw new WebError(`SearXNG returned an unprocessable response body: ${String(err)}`, 'WEB_PROVIDER_ERROR', { cause: err })
    }
  }
}

function isValidBaseUrl(baseURL: string): boolean {
  return URL.canParse(baseURL)
}

function isAbortError(error: unknown): boolean {
  return error instanceof DOMException && error.name === 'AbortError'
}
