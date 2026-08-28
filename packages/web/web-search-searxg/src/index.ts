import type { Context } from '@deepseek-ai/cordis'
import { launchEnvironmentOf } from '@deepseek-ai/dsh-launch-environment'
import z from '@deepseek-ai/schemastery'
import type {} from '@deepseek-ai/dsh-web'
import { SearxgSearchProvider, SEARXG_DEFAULT_BASE_URL } from './provider.ts'

export {
  SEARXG_DEFAULT_BASE_URL,
  SEARXG_PROVIDER_ID,
  SearxgSearchProvider,
} from './provider.ts'
export type { SearxgSearchProviderOptions } from './provider.ts'

export const name = 'web-search-searxg'

export const inject = ['web']

export interface Config {
  baseURL?: string
}

export const Config: z<Config> = z.object({
  baseURL: z.string(),
})

export function apply(ctx: Context, config: Config): void {
  ctx.web.registerSearchProvider(new SearxgSearchProvider({
    baseURL: config.baseURL ?? launchEnvironmentOf(ctx).get('SEARXG_BASE_URL')?.value ?? SEARXG_DEFAULT_BASE_URL,
  }))
}
