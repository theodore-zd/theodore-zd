# Dead-Code Removal Summary Format

After changes, emit a concise summary so the user can confirm nothing critical was removed. Split by phase — Phase 1 = `deadcode`-flagged unreachable funcs/methods, Phase 2 = manual sweep for categories `deadcode` doesn't cover.

```
## Dead Code Removed

### Phase 1 — deadcode (N)
- path/to/file.go:42 `funcName` — unreachable from main, no dynamic callers
- path/to/file.go:87 `(*Type).Method` — interface checked, no impls reachable

### Phase 2 — manual sweep (N)
- Unused const `MaxFoo` in path/to/file.go — no references found
- Unused struct field `Type.internalCache` — no readers/writers, no reflection tags
- Removed `_ "image/gif"` from path/to/file.go — no GIF decoding in project
- Removed 15 lines of commented-out code from path/to/old.go
- Dead file removed: path/to/orphan.go — package never imported

### Skipped (trap matches)
- `(*Foo).MarshalJSON` — implements `json.Marshaler`, kept
- `handleWebhook` — registered via `http.HandleFunc`, kept

### Verification
- [x] `go build ./...` passes
- [x] `go vet ./...` clean
- [ ] `go test ./...` (run to confirm)
```

The per-removal "why" is the user's confidence signal that nothing important was deleted. The "Skipped" section proves trap-verification actually ran — keep it in even when empty.
