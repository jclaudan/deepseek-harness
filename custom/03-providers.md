# 03 — Providers & Models

## Architecture
- `packages/bundle/base/cordis.patch.yml:107` `llm-pi-ai` (`@deepseek-ai/dsh-llm-pi-ai`) monté dormant : 0 routes tant que `llm-pi-ai:` absent de `settings.yaml`
- `packages/bundle/base/cordis.patch.yml:90` `settings` (`dsh-settings-file`) → `$DSH_HOME/settings.yaml` hot-reload
- `packages/bundle/base/cordis.patch.yml:94` `credentials` (`dsh-credentials-local`) → `$DSH_HOME/.credentials.yaml` + env
- `packages/llm/llm-pi-ai/src/index.ts:114` déclare `configurable-provider directory` (routes installées + routes déclarées)

## Page Models (`packages/client/ui-settings-models/src/client/`)
- `store.ts:42` `joinProviderDirectory(registered, directory)` : rows `declared` puis live sans déclaration
- `ModelsSection.tsx:321` `configured`/`configurable`/`addable` + `needsSetup()` (première run)
- `ProviderEditor.tsx` / `CustomProviderCard.tsx` : baseURL, api, models, `apiKeyEnv` → `credentials/describe`
- Écriture via `operations.writeSettings` (`settings/mutate` path ops) + `removeCredential`, reload `controller.load()`

## Notre custom actuel
`settings.yaml` (dans volume `dsh-home`) :
```yaml
llm:
  providers:
    janai: { baseURL: http://192.168.1.170:1337, apiKeyEnv: JANAI_API_KEY }
llm-pi-ai:
  providers:
    janai: { displayName: janai, apiKeyEnv: JANAI_API_KEY, api: openai-completions, baseURL: ..., models: [Qwen3_6..., ...] }
```

## Ajouter un provider
1. UI : `Settings → Models → Add provider` (ou `Add a custom provider` → route `^[a-z][a-z0-9-]*$`)
2. ou `settings.yaml` direct (hot-publish)
3. ou `cordis.patch.yml` overlay `llm-pi-ai` (non recommandé hors base)

## Credentials
`JANAI_API_KEY` peut être dans `.credentials.yaml` (managed) ou `process.env` (inherited). La page dérive `<ROUTE>_API_KEY` si `apiKeyEnv` vide (`store.ts:114` `deriveKeyRef`).
