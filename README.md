# homebrew-tap

Homebrew tap for [xin](https://xinproxy.com), an nginx-compatible reverse
proxy.

```sh
brew tap xinproxy/tap
brew install xin
brew services start xin
```

xin is proprietary software (`LicenseRef-xin-noncommercial`): free of
charge for non-commercial use, a paid licence required to serve production
traffic for a business. See https://xinproxy.com and the `LICENSE` file
installed alongside the binary.

Supported platforms: Linux (amd64/arm64) and macOS (Apple Silicon and
Intel).

`Formula/xin.rb` here is synced from `packaging/brew/Formula/xin.rb` in
[xinproxy/xin](https://github.com/xinproxy/xin) at release time; that repo
is the source of truth.
