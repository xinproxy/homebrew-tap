class Xinginx < Formula
  desc "Memory-safe reverse proxy with nginx-style configuration"
  homepage "https://xinproxy.com"
  version "0.2.1"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://dl.xinproxy.com/xinginx/0.2.1/xinginx-0.2.1-darwin-arm64.tar.gz"
      sha256 "6662c72f76556bc612e3628b53f7b28e916bda52b853874407dfe9befba03700"
    end
    on_intel do
      url "https://dl.xinproxy.com/xinginx/0.2.1/xinginx-0.2.1-darwin-amd64.tar.gz"
      sha256 "0ccd1f2490d5b680a8c40561c14f09d78cfdc3cd7df5b86c09afc7e64a348c18"
    end
  end

  on_linux do
    on_arm do
      url "https://dl.xinproxy.com/xinginx/0.2.1/xinginx-0.2.1-linux-arm64-musl.tar.gz"
      sha256 "840b0f0643ca0342a57a5fa09b74ded54fb9f8aaf9f0ca84adf923812cab23cd"
    end
    on_intel do
      url "https://dl.xinproxy.com/xinginx/0.2.1/xinginx-0.2.1-linux-amd64-musl.tar.gz"
      sha256 "b69cfa9b684aa8988731cbc9da1b76702c0791ac7e941865e8f27981d0df67e9"
    end
  end

  def install
    bin.install "sbin/xinginx"
    man8.install "share/man/man8/xinginx.8"
    doc.install "share/doc/xinginx/ACKNOWLEDGMENTS", "share/doc/xinginx/LICENSE"
    pkgshare.install "share/xin/html"

    (etc/"xinginx").install "share/doc/xinginx/xin.conf" => "xinginx.conf.default"
    (etc/"xinginx").install "share/doc/xinginx/mime.types"

    sample = etc/"xinginx/xinginx.conf.default"
    config = sample.read
                   .gsub("/var/log/xin", "#{var}/log/xinginx")
                   .gsub("/var/run/xin.pid", "#{var}/run/xinginx.pid")
                   .gsub("/run/xin.pid", "#{var}/run/xinginx.pid")
                   .gsub("listen 80 default_server;", "listen 8080 default_server;")
                   .gsub("listen [::]:80 default_server;", "listen [::]:8080 default_server;")
                   .gsub("root /usr/local/www/xin;", "root #{opt_pkgshare}/html;")
                   .gsub("root /var/www/html;", "root #{opt_pkgshare}/html;")
                   .gsub("include /etc/xin/mime.types;", "include #{etc}/xinginx/mime.types;")
                   .gsub("include mime.types;", "include #{etc}/xinginx/mime.types;")
    sample.atomic_write(config)
  end

  post_install_steps do
    unless_path_exists "xinginx/xinginx.conf", base: :etc do
      copy "xinginx/xinginx.conf.default", "xinginx/xinginx.conf", source_base: :etc, target_base: :etc
    end
    mkdir_p "log/xinginx", base: :var
    mkdir_p "run", base: :var
    mkdir_p "lib/xinginx", base: :var
  end

  service do
    run [opt_bin/"xinginx", "-c", etc/"xinginx/xinginx.conf"]
    keep_alive true
    log_path var/"log/xinginx/access.log"
    error_log_path var/"log/xinginx/error.log"
    working_dir HOMEBREW_PREFIX
    environment_variables STATE_DIRECTORY: var/"lib/xinginx"
  end

  def caveats
    <<~EOS
      The active configuration is #{etc}/xinginx/xinginx.conf. Upgrades preserve it;
      compare it with xinginx.conf.default to adopt new defaults. The included
      service listens on port 8080 so it can run without root privileges.

      Xin is free for non-commercial use or evaluation. Other commercial use
      requires a written license; read #{doc}/LICENSE and contact licensing@xinproxy.com.
    EOS
  end

  test do
    (testpath/"xinginx.conf").write <<~CONFIG
      events {}
      http {
        server {
          listen 8080;
          location / { return 200 "ok"; }
        }
      }
    CONFIG
    system bin/"xinginx", "-t", "-c", testpath/"xinginx.conf"
    assert_match version.to_s, shell_output("#{bin}/xinginx -v 2>&1")
  end
end
