---
name: gen-master-spec
description: Create comprehensive master specification files that document a project's architecture, organization, and how all components work together. Generates ./docs/master-spec.md (single-layer) or separate backend/frontend specs (full-stack) based on detected project structure.
compatibility: Requires Glob, Grep, Read, Write tools
---

# Codebase Spec Generator

This skill analyzes an entire codebase and creates comprehensive master specification files that document the project's architecture, organization, components, and how everything works together.

## Your Task

You are creating a technical master specification document(s) that serve as a complete, accurate reference for understanding the project. The spec should explain:

- What the project is and what it does
- How it's organized (directory structure, modules)
- Technologies used and why
- Key components/modules and their responsibilities
- How data flows through the system
- API endpoints and contracts (if applicable)
- Configuration and deployment
- Architecture patterns and design decisions

## Step 1: Analyze the Project Structure

Start by mapping the project:

1. **Read package.json, go.mod, requirements.txt, Cargo.toml, or similar** — Identify the primary language and framework
2. **List top-level directories** — Use `Glob` to get directory structure
3. **Identify frontend vs backend indicators:**
   - **Frontend indicators:** `src/`, `components/`, `pages/`, `package.json` with React/Vue/Angular/Svelte, `tsconfig.json`, `vite.config.js`
   - **Backend indicators:** `server/`, `api/`, `routes/`, `go.mod`, `requirements.txt`, `.go` files, Django/Flask/Express config

4. **Determine project type:**
   - Pure frontend (React, Vue, etc. only)
   - Pure backend (Express, Django, Go service, etc. only)
   - Full-stack (both frontend and backend clearly separated)

## Step 2: Deep Dive by Layer

### For Backend/API Layer:

1. **Identify the framework** — Is it Express, Django, Go, Rust, etc.?
2. **Find key directories:**
   - Routes/handlers
   - Models/database schemas
   - Services/business logic
   - Middleware
   - Configuration
3. **Map main routes/endpoints** — What does the API expose?
4. **Identify data storage** — Database type, ORM, schema structure
5. **Check for external integrations** — Third-party services, APIs
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
3. **Understand navigation/routing** — How does the app structure pages?
4. **Check state management** — Redux, Vuex, Context, Zustand?
5. **Identify data sources** — Where does data come from? (backend API, GraphQL, REST calls?)
6. **Note build and deployment** — How is it built and served?

## Step 3: Gather Critical Details

Use Grep and Read to understand:

- **Main entry points** — What's the starting point of each layer?
- **Key business logic** — What are the core operations?
- **Data models** — What entities/types exist?
- **API contracts** — Request/response formats (sample actual code if possible)
- **Configuration** — Environment variables, config files
- **Dependencies** — Major libraries and their purposes

## Step 4: Create the Master Spec

Choose the right output format based on what you found:

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

**`./docs/master-backend-spec.md`** — Document only the backend/API layer
**`./docs/master-frontend-spec.md`** — Document only the frontend layer

Each should follow the same structure as above, but focused on its layer.

## Step 5: Write with Precision

As you write each section:

1. **Be specific and accurate** — Reference actual files, directories, frameworks you found
2. **Include examples** — Show actual code patterns from the project where relevant
3. **Explain WHY** — Explain architectural choices and design decisions
4. **Use the actual project name** — Not generic "app" or "service"
5. **Add navigation** — Use markdown links to help readers navigate between sections
6. **Be comprehensive** — Cover all major components, not just the obvious ones

## Example sections to ensure you include:

For **Backend**:
- What framework/language/runtime
- Main HTTP methods and routes
- How authentication/authorization works
- Database: what type, schema overview
- External service integrations
- Error handling approach
- Rate limiting, caching strategies
- How the code is organized (MVC, services, etc.)

For **Frontend**:
- What framework/build tool
- Page/component structure
- How routing works
- State management approach
- How it communicates with backend
- Styling approach (CSS, tailwind, etc.)
- Build/dev/production setup
- Key dependencies and why they're used

## Output Checklist

Before finalizing, ensure the spec(s):

- [ ] Accurately reflect the actual codebase (use real paths, frameworks, versions)
- [ ] Include Table of Contents with working links
- [ ] Explain the project's purpose and architecture
- [ ] Document all major components/modules
- [ ] Show actual code patterns from the project
- [ ] Include enough detail for someone to understand the system
- [ ] Use clear, technical language
- [ ] Are well-organized and easy to navigate
- [ ] For full-stack: properly separate backend and frontend concerns
