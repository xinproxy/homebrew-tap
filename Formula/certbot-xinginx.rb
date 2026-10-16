class CertbotXinginx < Formula
  desc "Xinginx authenticator and installer plugin for Certbot"
  homepage "https://github.com/xinproxy/certbot/tree/main/certbot-xin"
  url "https://github.com/xinproxy/certbot/archive/1e4a22163a0805bfafc09d0e57740304db5f6b6e.tar.gz"
  version "5.9.0"
  sha256 "d034a756977eb3aecc29b1a70516369f81ab4bd686e75b9b7710ecd80085163f"
  license all_of: ["Apache-2.0", "MIT"]

  depends_on "certbot"
  depends_on "xinginx"

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

    (bin/"certbot-xinginx").write <<~SH
      #!/bin/sh
      export PYTHONPATH="#{opt_libexec}/plugin${PYTHONPATH:+:$PYTHONPATH}"
      exec "#{formula_opt_libexec("certbot")}/bin/certbot" "$@"
    SH
  end

  test do
    output = shell_output("#{bin}/certbot-xinginx plugins --text")
    assert_match "* xin", output
  end
end
