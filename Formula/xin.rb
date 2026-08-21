# xin — nginx-compatible reverse proxy, proprietary (LicenseRef-xin-noncommercial)
#
# This formula belongs in xinproxy/homebrew-tap (github.com/xinproxy/homebrew-tap),
# NOT homebrew-core — see packaging/brew/README.md for why homebrew-core is not
# reachable (closed source; and nginx already occupies this niche there) and
# why a formula, not a cask, was chosen.
#
# STATUS (2026-08-21): xinproxy/homebrew-tap exists and this file is synced
#   into it verbatim at release time — see README, "At each release".
#   dl is laid out as <package>/<version>/<file>, with <package>/latest a
#   symlink to the newest version. The formula pins the explicit version so
#   an install is reproducible; `latest` is for humans.
#
#   Linux is live: xin-0.1.4-linux-{amd64,arm64}[-musl].tar.gz are real,
#   published artifacts with hashes verified against SHA256SUMS.asc (signed
#   by the archive key documented in packaging/keys/README.md). The
#   on_linux block below is real, not aspirational.
#
#   Darwin artifacts exist too — xin-0.1.4-darwin-{amd64,arm64}.tar.gz
#   are published at dl.xinproxy.com with real hashes in SHA256SUMS,
#   verified the same way. See packaging/brew/README.md ("Darwin
#   artifacts") in the xin repo for the release-engineering state.
class Xin < Formula
  desc "nginx-compatible reverse proxy (proprietary, free for non-commercial use)"
  homepage "https://xinproxy.com"
  version "0.1.4"

  # xin's own licence identifier, an SPDX-style LicenseRef- string (see
  # /LICENSE at the repo root) rather than a catalogued SPDX id, because the
  # licence itself is not one of the standard ones: source-available,
  # gratis for non-commercial use, a paid licence required for production/
  # commercial use. `brew audit` validates `license` against SPDX's list and
  # LicenseRef-* is valid SPDX *syntax* for a user-defined licence, but
  # whether Homebrew's auditor accepts an arbitrary LicenseRef- string
  # is its call — if `brew audit --strict` (see
  # README) rejects it, the documented escape hatch is
  # `license :cannot_represent`, which exists for exactly this case. Left as
  # the real identifier for now because it is the more informative of the
  # two if it passes.
  license "LicenseRef-xin-noncommercial"

  on_macos do
    on_arm do
      url "https://dl.xinproxy.com/xin/0.1.4/xin-0.1.4-darwin-arm64.tar.gz"
      sha256 "6f64b8a67ed5a8d8a583e69192e01b42945f4de7ebf980fce62d44bf8e137111"
    end
    on_intel do
      url "https://dl.xinproxy.com/xin/0.1.4/xin-0.1.4-darwin-amd64.tar.gz"
      sha256 "5c64e7be618358e7554d0a65655dd1277ae5b70276df10d0cd3b40eb13ff685a"
    end
  end

  # Linuxbrew. Deliberately amd64/arm64 only — the two architectures
  # Homebrew itself officially runs on Linux (the x86_64_linux / arm64_linux
  # bottle tags). dl.xinproxy.com also ships i686, armv6, armv7, ppc64le and
  # s390x tarballs, and Debian/Fedora package all seven, but there is no
  # Homebrew-on-Linux platform to key an on_* block off for the other five,
  # so they are left out rather than guessed at. See README, "Linuxbrew:
  # yes, but" for whether shipping this block at all is a good idea.
  #
  # The *-musl (static) tarball is used here rather than the glibc/dynamic
  # one on purpose: it has no dependency on whatever glibc the Linuxbrew
  # host happens to have, which a formula resolved by architecture alone
  # (Homebrew does not check the host's glibc version) cannot otherwise
  # guarantee. Cost, same as documented for that tarball elsewhere in this
  # repo (packaging/release-notes.md): no NSS, so LDAP/SSSD-backed `user`
  # directives in an nginx.conf won't resolve.
  on_linux do
    on_arm do
      url "https://dl.xinproxy.com/xin/0.1.4/xin-0.1.4-linux-arm64-musl.tar.gz"
      sha256 "b47a1bf0f792c1264ced32d45dfe633bef16cea408b4f6d534f9fe7a32b1128e"
    end
    on_intel do
      url "https://dl.xinproxy.com/xin/0.1.4/xin-0.1.4-linux-amd64-musl.tar.gz"
      sha256 "91c19eed6aa8a00c80b413deb23ed5675eee5ed6642f96474a3ba0542f18bed1"
    end
  end

  def install
    # The tarball ships the binary at sbin/xin, matching /usr/sbin/xin in
    # the .deb and .rpm — the Linux convention for a binary normally started
    # by root (or, under systemd, by a broker that starts as root; see
    # packaging/debian/xin.service). Homebrew's `sbin` exists as a concept
    # (Formula#sbin) but, unlike `bin`, is not reliably on PATH: `brew
    # shellenv` has not consistently exported it across Homebrew versions
    # and platforms the way it does `bin`, and shells configured before that
    # changed will not pick it up at all. The failure mode
    # (xin installed, `xin` not found) is bad enough, and cheap enough
    # to avoid, that this formula installs to `bin`. See README for more.
    bin.install "sbin/xin"
    man8.install "share/man/man8/xin.8"
    doc.install "share/doc/xin/ACKNOWLEDGMENTS", "share/doc/xin/LICENSE"
    # Installed as the *sample*, not the active config — Homebrew never
    # decides what you proxy for you. `etc` here is
    # #{HOMEBREW_PREFIX}/etc/xin/, parallel to how Homebrew's own nginx
    # formula keeps its sample config under #{HOMEBREW_PREFIX}/etc/nginx/.
    (etc/"xin").install "share/doc/xin/xin.conf" => "xin.conf.default"
    # The shipped sample assumes the Linux package layout: logs under
    # /var/log/xin (root-owned, does not exist here) and listen 80 (needs
    # root). Rewrite the sample for the Homebrew environment the same way
    # homebrew-core's nginx formula does: logs under #{var}, port 8080, so
    # a user-run `brew services start xin` works out of the box.
    inreplace etc/"xin/xin.conf.default" do |sample|
      sample.gsub! "/var/log/xin", "#{var}/log/xin"
      sample.gsub! "listen 80 default_server;", "listen 8080 default_server;"
      sample.gsub! "listen [::]:80 default_server;", "listen [::]:8080 default_server;"
    end
  end

  def post_install
    # Seed a real, editable xin.conf from the sample on first install
    # only — an upgrade must never overwrite a config the user has since
    # edited. Same seed-vs-default convention as nginx's Homebrew formula,
    # but under xin's own name: the config file is xin.conf, matching the
    # /etc/xin/xin.conf default everywhere else xin ships.
    config = etc/"xin/xin.conf"
    config.write((etc/"xin/xin.conf.default").read) unless config.exist?
    (var/"log/xin").mkpath
  end

  service do
    # xin never daemonizes — packaging/docker/README.md: it runs a
    # privileged broker plus one serving process, both already in the
    # foreground — which is exactly the shape `brew services`/launchd wants
    # to supervise: one long-lived foreground process, no `-g "daemon
    # off;"` needed (and none accepted; see that README's note that `-g` is
    # parsed but not implemented).
    run [opt_bin/"xin", "-c", etc/"xin/xin.conf"]
    keep_alive true
    log_path var/"log/xin/access.log"
    error_log_path var/"log/xin/xin.log"
    working_dir HOMEBREW_PREFIX

    # Deliberately NOT require_root. `brew services start xin` under this
    # formula runs as the calling user, which cannot bind :80 or :443
    # (EACCES) — ports below 1024 need root on macOS same as everywhere
    # else. Homebrew's service DSL does support `require_root true`, which
    # would make `brew services` insist on `sudo brew services start xin`
    # and run the whole thing as root — but "the whole thing" is the
    # problem: launchd has no equivalent of the privileged-broker-then-
    # drop-capabilities split xin.service performs on Linux (see
    # packaging/debian/xin.service's CapabilityBoundingSet comments).
    # `require_root true` here would mean the entire proxy process stays
    # root for its whole life, which is a strictly worse security posture
    # than the systemd unit, not a neutral default. That should be an
    # operator's explicit, informed choice, not this formula's default. See
    # README, "Ports 80/443", and the caveats below for what to do instead.
  end

  test do
    # A real config, not a token file: exercises the property xin's whole
    # compatibility claim rests on (packaging/release-notes.md) — `xin -t`
    # on a config it accepts must actually accept it, and refuse anything it
    # doesn't understand rather than silently ignoring it.
    (testpath/"xin.conf").write <<~NGINX
      events {}
      http {
        server {
          listen 8080;
          location / { return 200 "ok"; }
        }
      }
    NGINX
    system bin/"xin", "-t", "-c", testpath/"xin.conf"

    # `-v` is nginx's own "print version and exit" flag; xin implements the
    # same flag (xin-facade-nginx/src/cli.rs) and should report the version
    # this formula thinks it installed. Output goes to stderr (measured
    # against real nginx, per that file's module comment), hence 2>&1.
    assert_match version.to_s, shell_output("#{bin}/xin -v 2>&1")
  end

  def caveats
    <<~EOS
      xin is proprietary software, free of charge for non-commercial use
      only (LicenseRef-xin-noncommercial). Read
        #{doc}/LICENSE
      before using it for anything beyond personal, academic, or evaluation
      use — evaluation does not extend to serving production traffic for a
      business. A commercial licence is required for that; see
      https://xinproxy.com.

      A sample config was installed to:
        #{etc}/xin/xin.conf.default
      and copied, on first install only, to:
        #{etc}/xin/xin.conf
      which is the file `brew services start xin` actually runs. xin reads
      whatever that file contains, exactly as nginx reads nginx.conf —
      edit it in place; nothing here regenerates it on upgrade.

      `brew services start xin` runs unprivileged. If your config binds a
      port below 1024 (80 and 443 are nginx's and xin's own conventional
      defaults) the bind will fail rather than silently choosing another
      port. For local testing, point your config at a port >= 1024 (the
      sample above uses 8080). To actually serve 80/443, run xin directly
      as root, outside brew services:
        sudo #{opt_bin}/xin -c #{etc}/xin/xin.conf
      which gets you the real ports but none of brew services' supervision
      (restart-on-crash, launchd registration). There is no privileged-
      broker/capability-drop model on macOS the way there is on Linux —
      see packaging/debian/xin.service's comments in the xin repository for
      what that looks like — and this formula does not attempt to
      reproduce it.
    EOS
  end
end
