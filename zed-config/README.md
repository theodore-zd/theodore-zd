# zed-config

Backup of the local Zed editor configuration (`~/.config/zed/`).

## Contents

- `settings.json` — Zed settings (JSONC), byte-copy of `~/.config/zed/settings.json`
- `keymap.json` — keybindings, byte-copy of `~/.config/zed/keymap.json`

`themes/` is empty locally, so nothing is backed up for it.

## Restore

```sh
cp zed-config/settings.json ~/.config/zed/settings.json
cp zed-config/keymap.json ~/.config/zed/keymap.json
```

## Edit predictions

`settings.json` enables edit predictions via the OpenAI-compatible API provider
pointed at OpenRouter (`https://openrouter.ai/api/v1/completions`, model
`deepseek/deepseek-v3.2`, FIM prompt format `glm`).

The API key is **not** stored in this repo. It is provided at runtime via the
environment variable:

```sh
export ZED_OPEN_AI_COMPATIBLE_EDIT_PREDICTION_API_KEY="sk-or-..."
```

(also persisted in `~/.zshrc` and `~/.config/environment.d/openrouter.conf`).