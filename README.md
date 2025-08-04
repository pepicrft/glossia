<p align="center">
    <img  width="150" src="./logo.svg"/>
</p>
<h1 align="center">Glossia</h1>
<div align="center">
    <!-- Badges -->
</div>
<p align="center">
    A modern language hub for your organization.
</p>

## Project Structure

This is a monorepo containing the following components:

- **`web/`** - Phoenix web application (Elixir/Erlang)
- **`cli/`** - Command-line interface (Go)

## Development

### Prerequisites

- [mise](https://mise.jdx.dev/) for managing development dependencies

### Set up

1. Clone the project: `git clone git@github.com:glossia/glossia.git`
2. Install dependencies: `mise install`

### Web Application

The web application is a Phoenix/Elixir application located in the `web/` directory.

```bash
# Run the web application locally
mise run dev/web

# Build the web application
mise run build/web

# Run web tests
mise run test/web

# Run web code checks
mise run check/web
```

### CLI

The CLI is a Go application located in the `cli/` directory.

```bash
# Build the CLI
mise run build/cli

# Run CLI tests
mise run test/cli

# Lint CLI code
mise run lint/cli

# Run the CLI locally
cd cli && go run main.go --help
```

## Usage

### Web Application

Check out [our documentation](https://docs.glossia.org) to learn more about how to use Glossia's hosted version, or how to self-host it.

### CLI

See the [CLI documentation](./cli/README.md) for detailed usage instructions.
