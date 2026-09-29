# Xin Homebrew tap

Homebrew tap for [xin](https://xinproxy.com), a memory-safe reverse proxy
with nginx-style configuration and a built-in MCP gateway. The formula is
pinned to **0.1.11** for macOS and Linux on Intel and ARM.

```sh
brew tap xinproxy/tap
brew trust xinproxy/tap   # Homebrew 6.0+ requires trusting third-party taps
brew install xinproxy/tap/xin
brew install xinproxy/tap/certbot-xin
brew services start xin
```

The installed service listens on port 8080 by default. Edit
`$(brew --prefix)/etc/xin/xin.conf` to configure your site; upgrades leave
that file alone. The `certbot-xin` command uses Homebrew's Certbot package
and the Xin plugin in its own Python environment. It does not install nginx's
Certbot plugin. See the [documentation](https://xinproxy.com/docs) and
[downloads](https://xinproxy.com/releases) for other platforms and packages.
