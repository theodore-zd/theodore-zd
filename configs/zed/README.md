# zed

Backup of the local Zed editor configuration (`~/.config/zed/`).

## Contents

- `settings.jsonc` — Zed settings (JSONC), copy of `~/.config/zed/settings.json`
- `keymap.jsonc` — keybindings (JSONC), copy of `~/.config/zed/keymap.json`

(`.jsonc` extensions here reflect the JSONC content; Zed reads them as `.json`.)

`themes/` is empty locally, so nothing is backed up for it.

## Restore

```sh
cp configs/zed/settings.jsonc ~/.config/zed/settings.json
cp configs/zed/keymap.jsonc ~/.config/zed/keymap.json
```

## Edit predictions

`settings.json` enables edit predictions via the OpenAI-compatible API provider
pointed at OpenRouter (`https://openrouter.ai/api/v1/completions`, model
`z-ai/glm-5.3-flash`, FIM prompt format `glm`).

The API key is **not** stored in this repo. It is provided at runtime via the
environment variable:

```sh
export ZED_OPEN_AI_COMPATIBLE_EDIT_PREDICTION_API_KEY="sk-or-..."
```

(also persisted in `~/.zshrc` and `~/.config/environment.d/openrouter.conf`).