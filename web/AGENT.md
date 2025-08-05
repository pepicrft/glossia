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
mise run check/web         # Run all checks before pushing changes
mise run check/web --fix   # Run checks and fix auto-fixable problems
```

The `check/web` command runs all necessary verification steps including tests, formatting, and linting. Always run this command before pushing changes upstream. If issues are found, use the `--fix` flag to automatically fix problems where possible.

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

## Documentation Maintenance

When making changes that affect configuration or deployment:
- Update `docs/contributors/self-hosting.md` with any new environment variables
- Document the purpose, format, and example values for each variable
- Keep OAuth provider setup instructions current
- Update example configurations if deployment patterns change

## Best Practices

### Pre-commit Checklist

**IMPORTANT**: Before committing and pushing any changes upstream, you MUST ensure all checks pass:

1. **Run ALL static checks** for the component you're working on:
   ```bash
   # For web changes
   mise run check/web
   
   # For CLI changes
   mise run check/cli
   ```

2. **Run tests** to ensure nothing is broken:
   ```bash
   # For web
   mix test
   
   # For CLI
   go test ./...
   ```

3. **Format code** properly:
   ```bash
   # For web (Elixir)
   mix format
   
   # For CLI (Go)
   go fmt ./...
   ```

4. **Build the project** to catch compilation errors:
   ```bash
   # For web
   mise run build/web
   
   # For CLI
   mise run build/cli
   ```

If ANY of these checks fail, fix the issues before committing. This prevents broken code from entering the main branch and ensures CI passes.

### General Best Practices

1. **Follow Phoenix conventions** - Use contexts, controllers, and views appropriately
2. **Use semantic commits** - Clear, descriptive commit messages
3. **Update documentation** - Keep environment variables and setup instructions current
4. **Test edge cases** - Don't just test the happy path
5. **Consider performance** - Think about database queries and N+1 problems

## CSS Architecture - EnduringCSS Methodology

This project follows the **EnduringCSS** methodology for organizing and maintaining CSS. **Every route must have its own CSS file** that contains all the styles specific to that route.

### 1. Route-Based CSS Files
- **Each Phoenix route must have a corresponding CSS file**
- CSS files are loaded per-route to ensure optimal performance
- Route CSS files contain all styles needed for that specific page

### 2. File Organization
```
assets/css/
├── app.css              # Global app styles (variables, reset, base)
├── marketing.css        # Marketing layout and shared marketing components
├── marketing/           # Marketing route-specific CSS files
│   ├── home.css        # Home page styles
│   ├── login.css       # Login page styles  
│   ├── blog-index.css  # Blog listing page
│   ├── blog-show.css   # Blog post page
│   └── changelog.css   # Changelog page
├── app/                 # App route-specific CSS files
│   ├── dashboard.css   # App dashboard
│   ├── projects.css    # Projects page
│   └── settings.css    # Settings page
└── components/          # Reusable component styles
    ├── navbar.css
    ├── footer.css
    └── forms.css
```

### 3. CSS Loading Strategy
- All CSS files are imported through the asset pipeline via `app.css`
- `app.css` imports `marketing.css` and all route-specific CSS files
- CSS files are bundled and served through Phoenix's asset pipeline
- Route-specific styles are always available but use proper namespacing to avoid conflicts

### 4. Naming Convention
- Use a namespace prefix for each module/component
- Format: `.[Namespace]_[Component]_[Element]--[Modifier]`
- Examples: 
  - `.Login_Form_Button--primary`
  - `.Home_Hero_Title--emphasized`
  - `.Blog_Post_Meta--highlighted`

### 5. Route CSS Implementation
Each route CSS file should:
- Contain all styles specific to that route
- Use the route name as the primary namespace
- Include responsive design for that route
- Define any route-specific component variants

### 6. Example Route CSS Structure
```css
/* routes/login.css */
.Login_Container { /* Main login container */ }
.Login_Form { /* Login form block */ }
.Login_Form_Button { /* Form button element */ }
.Login_Form_Button--primary { /* Primary button modifier */ }
.Login_Alternative { /* Alternative login options */ }
.Login_Footer { /* Login page footer */ }
```

### 7. CSS Import Strategy
All CSS is bundled through `app.css` using `@import` statements:

```css
/* app.css */
/* Import Marketing Layout and Route-specific CSS */
@import "./marketing.css";

/* Marketing Routes */
@import "./marketing/home.css";  
@import "./marketing/login.css";
@import "./marketing/blog.css";
@import "./marketing/changelog.css";

/* App Routes */
@import "./app/dashboard.css";
@import "./app/settings.css";
```

Templates should NOT import CSS directly - all styles are available through the bundled `app.css`.

/* components/navbar.css */
.Nav { /* Block */ }
.Nav_Logo { /* Element */ }
.Nav_Menu { /* Element */ }
.Nav_Menu--mobile { /* Modifier */ }
```

This methodology ensures maintainable, scalable CSS that grows well with the application.
