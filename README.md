# xin: xin isn't nginx

Homebrew tap for [xin](https://www.xinproxy.com),
an nginx-compatible reverse proxy.

```sh
brew tap xinproxy/tap
brew install xin
brew services start xin
```

Supported platforms: Linux (amd64/arm64) and macOS (Apple Silicon and
Intel).

`Formula/xin.rb` here is synced from `packaging/brew/Formula/xin.rb` in
[xinproxy/xin](https://github.com/xinproxy/xin) at release time; that repo
is the source of truth.
