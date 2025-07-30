# AGENT.md

This file provides guidance to AI coding assistants (like Claude Code, Cursor, etc.) when working with code in this repository.

## Monorepo Structure

Glossia is organized as a monorepo containing:
- **web/**: Phoenix web application (Elixir/Phoenix 1.7.20)
- **cli/**: Command-line interface (Go)

This document focuses on the web application in the `web/` directory.

## Project Overview

The Glossia web application creates language hubs for organizations. It's built with Elixir/Phoenix 1.7.20 and uses PostgreSQL as the database with Ecto for data management.

## Key Architecture

- **Phoenix Web Framework**: Standard Phoenix 1.7 structure with LiveView for interactive features
- **Database**: PostgreSQL with Ecto migrations and repo pattern
- **Frontend**:
  - Custom CSS for styling
  - ESBuild for JavaScript bundling
  - Phoenix LiveView for interactive components
- **Email**: Swoosh mailer with local adapter for development
- **Deployment**: Containerized with Docker, designed for Fly.io deployment

## Development Commands

All commands should be run from the `web/` directory.

### Setup and Dependencies
```bash
mix setup                    # Full project setup (deps, db, assets)
mix deps.get                # Install dependencies only
```

### Database Operations
```bash
mix ecto.setup              # Create database, run migrations, seed data
mix ecto.reset              # Drop and recreate database
mix ecto.create             # Create database
mix ecto.migrate            # Run pending migrations
mix ecto.rollback           # Rollback last migration
```

### Development Server
```bash
mix phx.server             # Start development server on localhost:7070
iex -S mix phx.server      # Start server with interactive Elixir shell
```

### Asset Management
```bash
mix assets.setup           # Install frontend build tools (esbuild)
mix assets.build           # Build assets for development
mix assets.deploy          # Build and optimize assets for production
```

### Testing
```bash
mix test                   # Run all tests (includes database setup)
mix test path/to/test.exs  # Run specific test file
mix test --only tag_name   # Run tests with specific tag
```

### Code Quality
```bash
mix credo                  # Run Credo linter for code quality
mix format                 # Format Elixir code using built-in formatter
```

### Pre-push Verification
```bash
mise run web:check         # Run all checks before pushing changes
mise run web:check --fix   # Run checks and fix auto-fixable problems
```

The `web:check` command runs all necessary verification steps including tests, formatting, and linting. Always run this command before pushing changes upstream. If issues are found, use the `--fix` flag to automatically fix problems where possible.

## Project Structure

### Core Application
- `lib/glossia/` - Core business logic and contexts
- `lib/glossia_web/` - Web interface (controllers, views, templates)
- `lib/glossia_web/components/` - Reusable Phoenix components
- `lib/glossia_web/controllers/` - HTTP request handlers

### Configuration
- `config/config.exs` - Base configuration
- `config/dev.exs` - Development environment settings (PostgreSQL on localhost:5432)
- `config/prod.exs` - Production configuration
- `config/runtime.exs` - Runtime configuration loaded from environment variables

### Frontend Assets
- `assets/js/app.js` - Main JavaScript entry point
- `assets/js/marketing.js` - Marketing site JavaScript
- `assets/css/app.css` - Main application CSS file
- `assets/css/marketing.css` - Marketing site CSS file
- `priv/static/` - Compiled static assets

### Database
- `priv/repo/migrations/` - Database migrations
- `priv/repo/seeds.exs` - Database seed data

## Development Environment

- **Database**: PostgreSQL with default credentials (postgres/postgres) on localhost:5432
- **Web Server**: Runs on http://127.0.0.1:7070 in development
- **Live Reload**: Automatically reloads on changes to templates, controllers, and assets
- **Email**: Uses local adapter - emails viewable at `/dev/mailbox` in development

## Testing Strategy

- Tests use separate test database (`glossia_test`)
- Database sandbox mode for test isolation
- Test files mirror the `lib/` structure in `test/`
- Support modules in `test/support/` (ConnCase, DataCase)

## Deployment

- Containerized application using multi-stage Docker build
- Production builds use `mix assets.deploy` for optimized assets
- Configured for Fly.io deployment with `fly.toml`

## CSS Architecture - EnduringCSS Methodology

This project follows the **EnduringCSS** methodology for organizing and maintaining CSS. The key principles are:

### 1. Component and Page Mapping
- Each Phoenix controller/page should have a corresponding CSS file
- Each component should have its own CSS namespace
- CSS files are organized to mirror the application structure

### 2. Naming Convention
- Use a namespace prefix for each module/component
- Format: `.[Namespace]_[Component]_[Element]--[Modifier]`
- Example: `.Marketing_Hero_Title--large`

### 3. File Organization
```
assets/css/
├── app.css           # Main app styles and imports
├── marketing.css     # Marketing site styles
├── pages/            # Page-specific styles
│   ├── home.css
│   ├── dashboard.css
│   └── blog.css
└── components/       # Component styles
    ├── navbar.css
    ├── footer.css
    └── forms.css
```

### 4. Isolation and Encapsulation
- Each CSS module is completely isolated
- No styles should "leak" between components
- Use explicit namespaces to avoid conflicts

### 5. State and Modifiers
- Use modifier classes for state changes
- Keep JavaScript classes separate from styling classes
- Example: `.Marketing_Button--disabled`, `.Marketing_Button--loading`

### 6. Example Structure
```css
/* marketing.css */
.Marketing_Hero { /* Block */ }
.Marketing_Hero_Title { /* Element */ }
.Marketing_Hero_Title--emphasized { /* Modifier */ }

/* components/navbar.css */
.Nav { /* Block */ }
.Nav_Logo { /* Element */ }
.Nav_Menu { /* Element */ }
.Nav_Menu--mobile { /* Modifier */ }
```

This methodology ensures maintainable, scalable CSS that grows well with the application.
