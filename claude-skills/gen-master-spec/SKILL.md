---
name: gen-master-spec
description: |
  Create comprehensive master specification files that document a project's architecture, organization, and how all components work together. Generates ./docs/master-spec.md (single-layer) or separate ./docs/master-backend-spec.md + ./docs/master-frontend-spec.md (full-stack) based on detected project structure.
  Trigger on phrases like "generate master spec", "document the architecture", "write a spec for this project", "summarize the codebase", "create a project spec", "architecture overview", or when the user asks for a top-level reference doc describing what the codebase does and how it fits together.
allowed-tools: Glob, Grep, Read, Write
---

# Codebase Spec Generator

This skill analyzes the whole codebase and creates master spec files documenting architecture, organization, components, and how they fit together.

## Your Task

Create technical master spec doc(s) — a complete reference for the project. The spec explains:

- What project do
- How organized (dirs, modules)
- Tech used + why
- Key components/modules + responsibilities
- Data flow
- API endpoints + contracts (if apply)
- Config + deployment
- Architecture patterns + design decisions

## Step 1: Analyze the Project Structure

Map project:

1. **Read package.json, go.mod, requirements.txt, Cargo.toml, or similar** — ID primary language + framework
2. **List top-level directories** — `Glob` for dir structure
3. **Identify frontend vs backend indicators:**
   - **Frontend indicators:** `src/`, `components/`, `pages/`, `package.json` with React/Vue/Angular/Svelte, `tsconfig.json`, `vite.config.js`
   - **Backend indicators:** `server/`, `api/`, `routes/`, `go.mod`, `requirements.txt`, `.go` files, Django/Flask/Express config

4. **Determine project type:**
   - Pure frontend (React, Vue, etc. only)
   - Pure backend (Express, Django, Go service, etc. only)
   - Full-stack (both separated)

## Step 2: Deep Dive by Layer

### For Backend/API Layer:

1. **Identify the framework** — Express, Django, Go, Rust?
2. **Find key directories:**
   - Routes/handlers
   - Models/database schemas
   - Services/business logic
   - Middleware
   - Configuration
3. **Map main routes/endpoints** — What API expose?
4. **Identify data storage** — DB type, ORM, schema
5. **Check for external integrations** — 3rd-party services, APIs
6. **Note architecture patterns** — MVC, microservices, layered, etc.

### For Frontend Layer:

1. **Identify the framework** — React, Vue, Svelte, Angular?
2. **Find key directories:**
   - Components
   - Pages/views
   - State management
   - API communication
   - Styling
   - Utilities/helpers
3. **Understand navigation/routing** — How app structure pages?
4. **Check state management** — Redux, Vuex, Context, Zustand?
5. **Identify data sources** — Where data from? (backend API, GraphQL, REST?)
6. **Note build and deployment** — How built + served?

## Step 3: Gather Critical Details

Grep + Read understand:

- **Main entry points** — Start point each layer?
- **Key business logic** — Core operations?
- **Data models** — Entities/types?
- **API contracts** — Request/response formats (sample real code if possible)
- **Configuration** — Env vars, config files
- **Dependencies** — Major libs + purpose

## Step 4: Create the Master Spec

Pick output format by finding:

### If ONLY Backend or ONLY Frontend

Use the template in `references/single-layer-template.md`. Save output to `./docs/master-spec.md`.

### If BOTH Frontend and Backend

Create two specs using:
- `references/backend-template.md` → save as `./docs/master-backend-spec.md`
- `references/frontend-template.md` → save as `./docs/master-frontend-spec.md`

Each focuses on its own layer; do not duplicate content between the two.

## Step 5: Write with Precision

Each section:

1. **Be specific and accurate** — Reference real files, dirs, frameworks found
2. **Include examples** — Show real code patterns where relevant
3. **Explain WHY** — Architectural choices + design decisions
4. **Use the actual project name** — Not generic "app" or "service"
5. **Add navigation** — Markdown links between sections
6. **Be comprehensive** — Cover all major components, not just obvious

## Example sections to ensure you include:

For **Backend**:
- Framework/language/runtime
- Main HTTP methods + routes
- Auth/authorization flow
- DB: type, schema overview
- External service integrations
- Error handling approach
- Rate limiting, caching
- Code organization (MVC, services, etc.)

For **Frontend**:
- Framework/build tool
- Page/component structure
- Routing
- State management
- Backend communication
- Styling (CSS, tailwind, etc.)
- Build/dev/prod setup
- Key deps + why

## Output Checklist

Before finalize, ensure spec(s):

- [ ] Reflect real codebase (real paths, frameworks, versions)
- [ ] Include Table of Contents w/ working links
- [ ] Explain purpose + architecture
- [ ] Doc all major components/modules
- [ ] Show real code patterns
- [ ] Enough detail to understand system
- [ ] Clear, technical language
- [ ] Well-organized, easy navigate
- [ ] Full-stack: separate backend + frontend concerns