# What is Glossia?

Glossia is a modern language hub designed to seamlessly integrate localization into your organization's continuous deployment workflow. It bridges the gap between traditional localization tools and modern software development practices.

## The Problem

Localization makes software more accessible and helps organizations expand to new markets. However, existing localization solutions often:

- Don't align with continuous deployment processes
- Create friction in development workflows
- Introduce unnecessary indirection
- Lead teams to avoid localization altogether

## Our Solution

Glossia leverages **LLMs with human-in-the-loop** to provide continuous localization that:

- Aligns with modern software development practices
- Integrates seamlessly into CI/CD pipelines
- Maintains high-quality translations
- Doesn't interrupt development workflows

## Key Features

### 🚀 Continuous Integration
Glossia integrates directly with your existing development workflow, treating translations as part of your continuous deployment process rather than a separate, disconnected activity.

### 🤖 AI-Powered with Human Oversight
By combining the speed and consistency of LLMs with human expertise for quality assurance, Glossia ensures translations are both fast and accurate.

### 🛠️ Developer-Friendly
Built with developers in mind, Glossia provides:
- A powerful CLI tool for local development
- GitHub integration for automated workflows
- Simple configuration and setup

### 🌍 Scalable Architecture
Whether you're localizing a small application or managing translations across multiple products, Glossia scales with your needs.

## Architecture

Glossia consists of two main components:

- **Web Application**: A Phoenix-based web application (Elixir/Erlang) that serves as the central hub for managing translations, reviewing changes, and coordinating with your team.

- **CLI Tool**: A Go-based command-line interface that integrates with your local development environment and CI/CD pipelines.

## Getting Started

Ready to modernize your localization workflow? Check out our [Quick Start Guide](/quickstart) to get Glossia up and running in minutes.