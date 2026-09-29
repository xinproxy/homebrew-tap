class Xin < Formula
  desc "Memory-safe reverse proxy with nginx-style configuration"
  homepage "https://xinproxy.com"
  version "0.1.12"
  license "LicenseRef-xin-noncommercial"

  on_macos do
    on_arm do
      url "https://dl.xinproxy.com/xin/0.1.12/xin-0.1.12-darwin-arm64.tar.gz"
      sha256 "22996faabda67a3c06067ce595ddec7878310559d1294f09560d82ef8a2f1969"
    end
    on_intel do
      url "https://dl.xinproxy.com/xin/0.1.12/xin-0.1.12-darwin-amd64.tar.gz"
      sha256 "3c8f6eede77c7fd9d0e4f973e233a1cf04780f7469dc84b8badf599c9329f56b"
    end
  end

  on_linux do
    on_arm do
      url "https://dl.xinproxy.com/xin/0.1.12/xin-0.1.12-linux-arm64-musl.tar.gz"
      sha256 "2c4871e608f6ca6d04453590ff3921e9d14bcecd82e3cde7140120fb92617764"
    end
    on_intel do
      url "https://dl.xinproxy.com/xin/0.1.12/xin-0.1.12-linux-amd64-musl.tar.gz"
      sha256 "68ed73adbb6b0d94754f73629eeb34fd0fbc4f2fcd745f16fa4c0584cd489e8c"
    end
  end

  def install
    bin.install "sbin/xin"
    man8.install "share/man/man8/xin.8"
    doc.install "share/doc/xin/ACKNOWLEDGMENTS", "share/doc/xin/LICENSE"
    pkgshare.install "share/xin/html"

    (etc/"xin").install "share/doc/xin/xin.conf" => "xin.conf.default"
    (etc/"xin").install "share/doc/xin/mime.types"

    sample = etc/"xin/xin.conf.default"
    config = sample.read
      .gsub("/var/log/xin", "#{var}/log/xin")
      .gsub("/var/run/xin.pid", "#{var}/run/xin.pid")
      .gsub("listen 80 default_server;", "listen 8080 default_server;")
      .gsub("listen [::]:80 default_server;", "listen [::]:8080 default_server;")
      .gsub("root /usr/local/www/xin;", "root #{opt_pkgshare}/html;")
      .gsub("include /etc/xin/mime.types;", "include #{etc}/xin/mime.types;")
    sample.atomic_write(config)
  end

  def post_install
    config = etc/"xin/xin.conf"
    config.write((etc/"xin/xin.conf.default").read) unless config.exist?
    (var/"log/xin").mkpath
    (var/"run").mkpath
    (var/"lib/xin").mkpath
  end

  service do
    run [opt_bin/"xin", "-c", etc/"xin/xin.conf"]
    keep_alive true
    log_path var/"log/xin/access.log"
    error_log_path var/"log/xin/error.log"
    working_dir HOMEBREW_PREFIX
    environment_variables STATE_DIRECTORY: var/"lib/xin"
  end

  test do
    (testpath/"xin.conf").write <<~CONFIG
      events {}
      http {
        server {
          listen 8080;
          location / { return 200 "ok"; }
        }
      }
    CONFIG
    system bin/"xin", "-t", "-c", testpath/"xin.conf"
    assert_match version.to_s, shell_output("#{bin}/xin -v 2>&1")
  end

  def caveats
    <<~EOS
      The active configuration is #{etc}/xin/xin.conf. Upgrades preserve it;
      compare it with xin.conf.default to adopt new defaults. The included
      service listens on port 8080 so it can run without root privileges.

      Xin is free for non-commercial use or evaluation. Other commercial use
      requires a written license; read #{doc}/LICENSE and contact licensing@xinproxy.com.
    EOS
  end
end
