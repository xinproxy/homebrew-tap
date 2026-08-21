# xin: xin isn't nginx

Homebrew tap for [xin](https://www.xinproxy.com),
an nginx-compatible reverse proxy.

```sh
brew tap xinproxy/tap
brew trust xinproxy/tap   # Homebrew 6.0+ requires trusting third-party taps
brew install xin
brew services start xin
```

Supported platforms: Linux (amd64/arm64) and macOS (Apple Silicon and
Intel).
