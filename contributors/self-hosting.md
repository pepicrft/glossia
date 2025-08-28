# Self-Hosting Glossia

This document describes all environment variables used to configure a self-hosted Glossia instance.

## Required Environment Variables

### Database Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection URL | `postgres://user:pass@localhost:5432/glossia` |
| `DATABASE_HOSTNAME` | PostgreSQL hostname (optional, overrides DATABASE_URL hostname) | `db.example.com` |

### Application Configuration

| Variable | Description | Example |
|----------|-------------|---------|
| `PHX_HOST` | The hostname where your instance will be accessible | `glossia.example.com` |
| `PORT` | The port the application will listen on | `8080` |
| `SECRET_KEY_BASE` | Secret key for session encryption (generate with `mix phx.gen.secret`) | 64+ character string |
| `PHX_SERVER` | Set to `true` to start the web server | `true` |

## OAuth Authentication

Glossia currently supports authentication via GitHub. Support for GitLab and other git forges is planned for future releases.

### GitHub OAuth

1. Create a new OAuth App at https://github.com/settings/developers
2. Set Authorization callback URL to: `https://your-domain.com/auth/github/callback`

| Variable | Description | Example |
|----------|-------------|---------|
| `GITHUB_CLIENT_ID` | GitHub OAuth App Client ID | `Iv23li2qoyzLF8ITSf0S` |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth App Client Secret | `ac0ef2db385ddc23e403dce0d4361ca94973a2df` |

## Email Configuration

Glossia supports multiple email adapters. Configure based on your needs:

### SMTP Configuration

Set `EMAIL_ADAPTER=smtp` and configure:

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `EMAIL_ADAPTER` | Email adapter to use | `local` | `smtp` |
| `EMAIL_SMTP_RELAY` | SMTP server hostname | - | `smtp.sendgrid.net` |
| `EMAIL_SMTP_USERNAME` | SMTP authentication username | - | `apikey` |
| `EMAIL_SMTP_PASSWORD` | SMTP authentication password | - | `SG.xxxxx` |
| `EMAIL_SMTP_PORT` | SMTP server port | `587` | `587` |
| `EMAIL_SMTP_SSL` | Use SSL/TLS | `false` | `true` |
| `EMAIL_SMTP_AUTH` | Authentication method | `if_available` | `always` |
| `EMAIL_SMTP_RETRIES` | Number of retries | `0` | `2` |
| `EMAIL_SMTP_NO_MX_LOOKUPS` | Disable MX lookups | `true` | `false` |

### SendGrid Configuration

Set `EMAIL_ADAPTER=sendgrid` and configure:

| Variable | Description | Example |
|----------|-------------|---------|
| `EMAIL_ADAPTER` | Email adapter to use | `sendgrid` |
| `EMAIL_SENDGRID_API_KEY` | SendGrid API Key | `SG.xxxxx` |

### AWS SES Configuration

Set `EMAIL_ADAPTER=ses` and configure:

| Variable | Description | Example |
|----------|-------------|---------|
| `EMAIL_ADAPTER` | Email adapter to use | `ses` |
| `EMAIL_SES_ACCESS_KEY` | AWS Access Key ID | `AKIAXXXXXXXXXXXXXXXX` |
| `EMAIL_SES_SECRET` | AWS Secret Access Key | `xxxxx` |
| `EMAIL_SES_REGION` | AWS Region | `us-east-1` |

### General Email Settings

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `EMAIL_FROM` | Default sender email address | `hello@glossia.ai` | `noreply@example.com` |
| `EMAIL_FROM_NAME` | Default sender name | `Glossia` | `My Glossia Instance` |

## Optional Configuration

### Fly.io Specific

| Variable | Description | Example |
|----------|-------------|---------|
| `FLY_APP_NAME` | Fly.io application name | `glossia` |
| `ERL_AFLAGS` | Erlang flags | `-proto_dist inet6_tcp` |

### Development Mode

In development, you can use hardcoded OAuth credentials by not setting the environment variables. The application will use the default development credentials configured in `config/runtime.exs`.

## Example Docker Compose Configuration

```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: glossia
      POSTGRES_USER: glossia
      POSTGRES_PASSWORD: changeme
    volumes:
      - postgres_data:/var/lib/postgresql/data

  glossia:
    image: glossia/glossia:latest
    ports:
      - "8080:8080"
    environment:
      DATABASE_URL: postgres://glossia:changeme@db:5432/glossia
      PHX_HOST: localhost
      PORT: 8080
      SECRET_KEY_BASE: your-secret-key-base-here
      PHX_SERVER: true
      
      # OAuth - GitHub
      GITHUB_CLIENT_ID: your-github-client-id
      GITHUB_CLIENT_SECRET: your-github-client-secret
      
      # Email - example with SMTP
      EMAIL_ADAPTER: smtp
      EMAIL_SMTP_RELAY: smtp.example.com
      EMAIL_SMTP_USERNAME: your-username
      EMAIL_SMTP_PASSWORD: your-password
      EMAIL_FROM: noreply@example.com
      
    depends_on:
      - db

volumes:
  postgres_data:
```

## Generating Secrets

To generate a secure `SECRET_KEY_BASE`:

```bash
mix phx.gen.secret
```

Or using OpenSSL:

```bash
openssl rand -base64 64 | tr -d '\n'
```

## Troubleshooting

1. **OAuth callback URLs must match exactly** - Ensure your callback URLs in the OAuth provider settings match your `PHX_HOST` configuration.

2. **Database migrations** - Run migrations after starting the application:
   ```bash
   mix ecto.migrate
   ```

3. **Email in development** - Use `EMAIL_ADAPTER=local` to view emails at `/dev/mailbox` during development.

4. **SSL/TLS** - In production, always use HTTPS. Configure your reverse proxy (nginx, caddy, etc.) to handle SSL termination.