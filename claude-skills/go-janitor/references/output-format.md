# Dead-Code Removal Summary Format

After changes, emit a concise summary so the user can confirm nothing critical was removed:

```
## Dead Code Removed

### Files removed (N)
- path/to/dead_file.go — package `foo`, never imported

### Unused exports removed (N)
- `ExportedFunc` from path/to/file.go — no callers outside package `bar`
- `HelperType` from path/to/types.go — no references found

### Unused functions removed (N)
- `helperFunc` in path/to/file.go — no call sites in package

### Dead imports cleaned (N)
- Removed `_ "image/gif"` from path/to/file.go — no GIF decoding in project

### Other cleanup (N)
- Removed 15 lines of commented-out code from path/to/old.go

### Verification
- [x] `go build ./...` passes
- [x] `go vet ./...` clean
- [ ] `go test ./...` (run to confirm)
```

The per-removal "why" is important — it's the user's confidence signal that nothing important was deleted.
