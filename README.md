# devcontainer

Shared VS Code dev container image with Claude Code, Python, and development tooling.

## What's Included

- **Node.js 24** LTS
- **Claude Code** CLI (native installer with auto-update)
- **Python 3.14** + **uv** package manager
- **zsh** with Powerlevel10k, fzf, git-delta
- **gh** CLI, nano, vim, jq
- Python build dependencies (libssl, libffi, etc.)
- PostgreSQL client
- Optional network firewall script

## Usage

Reference the image in your project's `.devcontainer/devcontainer.json`:

```json
{
  "image": "ghcr.io/stuartparmenter/devcontainer:latest",
  "customizations": {
    "vscode": {
      "extensions": [
        "anthropic.claude-code"
      ]
    }
  }
}
```

## Firewall

The image includes `init-firewall.sh` for restricting outbound network access to whitelisted domains. To enable it, add to your `devcontainer.json`:

```json
{
  "runArgs": ["--cap-add=NET_ADMIN", "--cap-add=NET_RAW"],
  "postStartCommand": "sudo /usr/local/bin/init-firewall.sh",
  "waitFor": "postStartCommand"
}
```

## Releases

Images are published to `ghcr.io/stuartparmenter/devcontainer` on each GitHub release. Tags follow semver (`v1.0.0`, `v1.0`, `v1`, `latest`).

## License

MIT
