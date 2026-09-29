class CertbotXin < Formula
  desc "Xin authenticator and installer plugin for Certbot"
  homepage "https://github.com/xinproxy/certbot/tree/main/certbot-xin"
  url "https://github.com/xinproxy/certbot/archive/1e4a22163a0805bfafc09d0e57740304db5f6b6e.tar.gz"
  sha256 "d034a756977eb3aecc29b1a70516369f81ab4bd686e75b9b7710ecd80085163f"
  version "5.9.0"
  license "Apache-2.0 AND MIT"

  depends_on "certbot"
  depends_on "xin"

  def install
    plugin = libexec/"plugin"
    plugin.install buildpath/"certbot-xin/src/certbot_xin"

    metadata = plugin/"certbot_xin-#{version}.dist-info"
    metadata.mkpath
    (metadata/"METADATA").write("Metadata-Version: 2.1\nName: certbot-xin\nVersion: #{version}\n")
    (metadata/"entry_points.txt").write(
      "[certbot.plugins]\nxin = certbot_xin._internal.entrypoint:ENTRYPOINT\n",
    )
    pkgshare.install "certbot-xin/LICENSE.txt", "certbot-xin/NOTICE"

    (bin/"certbot-xin").write <<~SH
      #!/bin/sh
      export PYTHONPATH="#{opt_libexec}/plugin${PYTHONPATH:+:$PYTHONPATH}"
      exec "#{Formula["certbot"].opt_libexec}/bin/certbot" "$@"
    SH
  end

  test do
    output = shell_output("#{bin}/certbot-xin plugins --text")
    assert_match "* xin", output
  end
end
