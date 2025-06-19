# Glossia CLI

A command-line interface for managing translations and language resources in your organization.

## Installation

### From Source

```bash
go install github.com/glossia/glossia/cli@latest
```

## Usage

### Initialize a new project

```bash
glossia init my-project
```

### Show version

```bash
glossia version
```

### Get help

```bash
glossia --help
```

## Development

### Build

```bash
go build -o glossia main.go
```

### Test

```bash
go test ./...
```

### Run locally

```bash
go run main.go --help
```

## Commands

- `init` - Initialize a new Glossia project with configuration
- `version` - Show the CLI version
- `help` - Show help information

More commands will be added as the CLI evolves to support extraction, generation, and management of translation files.