# Xin Homebrew tap

Homebrew tap for [xinginx](https://xinproxy.com), a memory-safe reverse proxy
with nginx-style configuration and a built-in MCP gateway. The formula is
pinned to **0.2.1** for macOS and Linux on Intel and ARM.

```sh
brew tap xinproxy/tap
brew trust xinproxy/tap   # Homebrew 6.0+ requires trusting third-party taps
brew install xinproxy/tap/xinginx
brew install xinproxy/tap/certbot-xinginx
brew services start xinginx
```

The installed service listens on port 8080 by default. Edit
`$(brew --prefix)/etc/xinginx/xinginx.conf` to configure your site; upgrades leave
that file alone. The `certbot-xinginx` command uses Homebrew's Certbot package
and the Xin plugin in its own Python environment. It does not install nginx's
Certbot plugin. See the [documentation](https://xinproxy.com/docs) and
[downloads](https://xinproxy.com/releases) for other platforms and packages.
