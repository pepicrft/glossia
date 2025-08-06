<p align="center">
    <img  width="150" src="./logo.svg"/>
</p>
<h1 align="center">✨ Glossia ✨</h1>
<div align="center">
    <!-- Badges -->
</div>
<p align="center">
    🌍 A modern language hub for your organization 🚀
</p>

---

**Localization makes software more accessible**, helping you expand to new markets. However, existing solutions don't align with continuous deployment processes, leading to friction and indirection that makes teams avoid localization altogether.

We believe **LLMs with human-in-the-loop** can align with modern software practices to continuously localize your software without compromising quality or interrupting development workflows.

---

## 📦 Components

This monorepo contains:

- **`web/`** - 🌐 Phoenix web application (Elixir/Erlang)
- **`cli/`** - 🛠️ Command-line interface (Go)

## 🐳 Docker Image

Pull the latest Docker image from GitHub Container Registry:

```bash
docker pull ghcr.io/pepicrft/glossia:latest
```

View all available tags: [ghcr.io/pepicrft/glossia](https://github.com/pepicrft/glossia/pkgs/container/glossia)

## 💻 Installation

### 🎯 Recommended: Install with mise

The easiest way to install Glossia on any platform is using [mise](https://mise.jdx.dev/):

```bash
# Install the latest version
mise use -g ubi:pepicrft/glossia

# Or install a specific version
mise use -g ubi:pepicrft/glossia@0.5.0
```

This works on macOS, Linux, and Windows (via WSL).

### 🍎 macOS

Download the appropriate binary for your architecture:
- [Intel Mac (x86_64)](https://github.com/pepicrft/glossia/releases/latest/download/glossia-x86_64-apple-darwin.tar.gz)
- [Apple Silicon (M1/M2)](https://github.com/pepicrft/glossia/releases/latest/download/glossia-aarch64-apple-darwin.tar.gz)

```bash
# Extract and install
tar -xzf glossia-*.tar.gz
chmod +x glossia
sudo mv glossia /usr/local/bin/
```

### 🐧 Linux

Download for your architecture:
- [x86_64](https://github.com/pepicrft/glossia/releases/latest/download/glossia-x86_64-unknown-linux-gnu.tar.gz)
- [ARM64](https://github.com/pepicrft/glossia/releases/latest/download/glossia-aarch64-unknown-linux-gnu.tar.gz)
- [ARMv7](https://github.com/pepicrft/glossia/releases/latest/download/glossia-armv7-unknown-linux-gnueabihf.tar.gz)

```bash
# Extract and install
tar -xzf glossia-*.tar.gz
chmod +x glossia
sudo mv glossia /usr/local/bin/
```

### 🪟 Windows

Download for your architecture:
- [x86_64](https://github.com/pepicrft/glossia/releases/latest/download/glossia-x86_64-pc-windows-msvc.tar.gz)
- [ARM64](https://github.com/pepicrft/glossia/releases/latest/download/glossia-aarch64-pc-windows-msvc.tar.gz)

Extract the archive and add the `glossia.exe` to your PATH.

## 🚀 Quick Start

### CLI Usage

```bash
# Initialize a new project
glossia init

# Check version
glossia --version

# Get help
glossia --help
```

### 🐳 Running with Docker

```bash
# Run the latest version
docker run -p 7070:7070 ghcr.io/pepicrft/glossia:latest

# Run with environment variables
docker run -p 7070:7070 \
  -e DATABASE_URL=postgresql://user:pass@host/db \
  -e PHX_HOST=glossia.example.com \
  ghcr.io/pepicrft/glossia:latest
```

## 📚 Resources

- 🌟 [Latest Release](https://github.com/pepicrft/glossia/releases/latest)
- 🐳 [Docker Images](https://github.com/pepicrft/glossia/pkgs/container/glossia)
- 🐛 [Report Issues](https://github.com/pepicrft/glossia/issues)
- 💬 [Discussions](https://github.com/pepicrft/glossia/discussions)

## 📄 License

Glossia is licensed under the FSL-1.1-MIT license. See [LICENSE.md](./LICENSE.md) for details.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](./CONTRIBUTING.md) for details.

---

<p align="center">
    Made with ❤️ by the Glossia team
</p>