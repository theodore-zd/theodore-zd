# Go Patterns That Look Dead But Aren't

Before removing any symbol, check whether it matches one of these patterns. Wrong = broken build or subtle runtime failures.

| Pattern | Why it's not dead |
|---------|-------------------|
| `var _ Interface = (*Type)(nil)` | Compile-time interface check |
| `func init() { ... }` | Runs on package import, no explicit caller |
| `_ "database/sql/driver"` | Side-effect import, registers a driver |
| `//go:embed files/*` | Compiler directive, referenced at build time |
| `//go:generate ...` | Build tooling directive |
| `//go:linkname localName pkg.remoteName` | Links to unexported symbol in another package |
| `//export FuncName` | CGo export, called from C code |
| `func (t *Type) MarshalJSON() ...` | Called by `encoding/json` via interface, never explicitly |
| `func (t *Type) String() string` | Called by `fmt` via `Stringer` interface |
| `func (t *Type) Error() string` | Called by error handling via `error` interface |
| Methods matching `Scan`, `Value` | Called by `database/sql` via interfaces |
| Unexported fields with struct tags | Populated by reflection-based unmarshalers |
