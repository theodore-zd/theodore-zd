---
name: gen-master-spec
description: Create comprehensive master specification files that document a project's architecture, organization, and how all components work together. Generates ./docs/master-spec.md (single-layer) or separate backend/frontend specs (full-stack) based on detected project structure.
compatibility: Requires Glob, Grep, Read, Write tools
---

# Codebase Spec Generator

Skill analyze whole codebase, create master spec files documenting architecture, organization, components, how fit together.

## Your Task

Create technical master spec doc(s) = complete reference for project. Spec explain:

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

### If ONLY Backend or ONLY Frontend: Create `./docs/master-spec.md`

```markdown
# Master Specification - [Project Name]

## Table of Contents
- [Overview](#overview)
- [Project Organization](#project-organization)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Key Components](#key-components)
- [Data Models](#data-models)
- [API Endpoints](#api-endpoints) (if backend)
- [Configuration](#configuration)
- [Deployment](#deployment)

## Overview
[2-3 sentences on what the project does and its purpose]

## Project Organization
[Directory structure and what each part does]

## Technology Stack
[Language, framework, key libraries and versions]

## Architecture
[How the system is structured, design patterns, key decisions]

## Key Components
[Main modules/services/components and what they do]

## Data Models
[Core entities and their structure]

## API Endpoints (Backend only)
[Main routes, their purposes, request/response examples]

## Configuration
[How to configure, environment variables, secrets]

## Deployment
[How to build and deploy the project]
```

### If BOTH Frontend and Backend: Create TWO specs

**`./docs/master-backend-spec.md`** — Doc backend/API layer only
**`./docs/master-frontend-spec.md`** — Doc frontend layer only

Each follow same structure, focus own layer.

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