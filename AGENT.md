# AGENT.md

This file provides guidance to AI coding assistants (like Claude Code, Cursor, etc.) when working with code in this repository.

## Repository Overview

Glossia is a modern translation platform that seamlessly integrates with development workflows. It provides continuous localization powered by AI, delivered through merge queues.

### Repository Structure

This is a monorepo containing:
- **web/**: Phoenix web application (Elixir/Phoenix 1.7.20)
- **cli/**: Command-line interface (Go)

## Web Application Architecture

The web application in the `web/` directory is built with:
- **Framework**: Phoenix 1.7.20 with LiveView
- **Language**: Elixir 1.17.3
- **Database**: PostgreSQL with Ecto ORM
- **Authentication**: UeberAuth (currently GitHub only)
- **Frontend**: ESBuild, Phoenix LiveView, and custom CSS
- **Deployment**: Docker containers, configured for Fly.io

### Key Technologies

- **Phoenix LiveView**: For interactive components without JavaScript
- **Ecto**: Database wrapper and query generator
- **UUIDv7**: Used as primary keys for all database models
- **EnduringCSS**: CSS architecture methodology (see below)

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

### Testing and Quality
```bash
mix test                   # Run all tests
mix format                 # Format Elixir code
mix credo                  # Run Credo linter
mise run lint/web          # Run all checks before pushing
mise run lint/web --fix    # Run checks and fix auto-fixable problems
```

## CSS Architecture - EnduringCSS Methodology

This project follows the **EnduringCSS** methodology for organizing and maintaining CSS. This is a critical architectural decision that must be followed.

### Core Principles

1. **Page-Based Organization**: Every Phoenix page/controller should have a corresponding CSS file
2. **Component Isolation**: Each component has its own CSS namespace
3. **No Global Styles**: Avoid global selectors except in base reset
4. **Explicit Naming**: Use descriptive, namespaced class names

### File Structure

```
web/assets/css/
├── app.css              # Main app styles and imports
├── marketing.css        # Marketing site styles
├── pages/               # Page-specific styles (1:1 with controllers)
│   ├── home.css        # Corresponds to PageController home action
│   ├── dashboard.css   # Corresponds to PageController dashboard action
│   ├── blog.css        # Corresponds to BlogController
│   └── changelog.css   # Corresponds to ChangelogController
└── components/          # Reusable component styles
    ├── navbar.css
    ├── footer.css
    └── forms.css
```

### Naming Convention

Use a namespace prefix for each module/component:
- Format: `.[Namespace]_[Component]_[Element]--[Modifier]`
- Examples:
  - `.Blog_Article`
  - `.Blog_Article_Title`
  - `.Blog_Article_Title--featured`
  - `.Marketing_Button--primary`

### Implementation Rules

1. **Create a CSS file for every new page**:
   ```elixir
   # When creating lib/glossia_web/controllers/pricing_controller.ex
   # Also create assets/css/pages/pricing.css
   ```

2. **Use page-specific namespaces**:
   ```css
   /* pages/blog.css */
   .Blog_Container { }
   .Blog_Post { }
   .Blog_Post_Title { }
   ```

3. **Import page CSS in the main file**:
   ```css
   /* marketing.css or app.css */
   @import "./pages/blog.css";
   ```

4. **Never use generic class names**:
   ```css
   /* Bad */
   .container { }
   .title { }
   
   /* Good */
   .Blog_Container { }
   .Blog_Title { }
   ```

## Environment Configuration

The application uses environment-based configuration. Key variables:

### Required
- `DATABASE_URL` - PostgreSQL connection string
- `PHX_HOST` - Hostname for the application
- `SECRET_KEY_BASE` - Session encryption key

### OAuth (GitHub)
- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`

### Email
- `EMAIL_ADAPTER` - (smtp, sendgrid, ses, local)
- Various adapter-specific settings

See `docs/contributors/self-hosting.md` for complete documentation.

## Documentation Maintenance

When making changes that affect configuration or deployment:
- Update `docs/contributors/self-hosting.md` with any new environment variables
- Document the purpose, format, and example values for each variable
- Keep OAuth provider setup instructions current
- Update example configurations if deployment patterns change

## Authentication System

Currently supports GitHub OAuth only. The system uses:
- UeberAuth for OAuth handling
- UUIDv7 for user and identity IDs
- Session-based authentication

Future plans include support for GitLab and Forgejo/Codeberg.

## Database Schema

All models use UUIDv7 as primary keys via `Glossia.Schema`:

```elixir
use Glossia.Schema  # Instead of use Ecto.Schema
```

Key models:
- `Account` - Organization accounts
- `User` - Individual users
- `Auth2Identity` - OAuth provider identities

## Best Practices

### GitHub Actions Conventions

When writing GitHub Actions workflows, follow these conventions:

1. **Use `working-directory` instead of `cd` commands**:
   ```yaml
   # Bad - using cd command
   - name: Build CLI
     run: cd cli && go build ./...
   
   # Good - using working-directory
   - name: Build CLI
     working-directory: cli
     run: go build ./...
   ```

2. **Keep logic in mise tasks**: Complex build/release logic should be in mise tasks under `mise/tasks/`, not inline in workflows

3. **Use matrix builds sparingly**: For Go cross-compilation, build all platforms from a single Ubuntu runner using GOOS/GOARCH

4. **Capitalize job names**: Use PascalCase for job names in workflows for consistency:
   ```yaml
   jobs:
     Check:       # Good - capitalized
       runs-on: ubuntu-latest
     
     Build:       # Good - capitalized
       needs: Check
       runs-on: ubuntu-latest
   
     # Bad examples:
     # check:     # lowercase
     # cli-build: # kebab-case
   ```

### Pre-commit Checklist

**IMPORTANT**: Before committing and pushing any changes upstream, you MUST ensure all checks pass:

1. **Run ALL static checks** for the component you're working on:
   ```bash
   # For web changes
   mise run lint/web
   
   # For CLI changes
   mise run lint/cli
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

1. **Always use EnduringCSS methodology** - Create CSS files for new pages
2. **Follow Phoenix conventions** - Use contexts, controllers, and views appropriately
3. **Test your changes** - Run `mix test` before committing
4. **Format code** - Run `mix format` before committing
5. **Update documentation** - Keep environment variables documented
6. **Use semantic commits** - Clear, descriptive commit messages

## Common Tasks

### Adding a New Page
1. Create the controller action
2. Create the template in `*_html/`
3. Create the CSS file in `assets/css/pages/`
4. Import the CSS file
5. Use namespaced classes in the template

### Adding a New OAuth Provider
Currently not supported due to package compatibility. GitHub is the only supported provider.

### Modifying Database Schema
1. Generate migration: `mix ecto.gen.migration name`
2. Ensure UUIDs are used for new tables
3. Run migration: `mix ecto.migrate`

## Deployment

The application is containerized and configured for Fly.io deployment:
- See `Dockerfile` for build configuration
- See `fly.toml` for deployment settings
- Environment variables are managed through Fly secrets

## CLI Application

The CLI in the `cli/` directory is a separate Go application. See `cli/README.md` for details.

## Getting Help

- Check existing code for patterns
- Run `mix help` for available tasks
- Consult Phoenix documentation
- Review `docs/contributors/` for internal documentation