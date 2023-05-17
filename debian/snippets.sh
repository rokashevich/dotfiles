apt install curl jq

URL="$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest \
  |jq -r '.assets[]
    |select(.browser_download_url
      |contains("k9s_Linux_amd64.tar.gz")).browser_download_url')"

rm -rf /my-portables
mkdir -p /my-portables/usr/bin

curl -sL "${URL}" | tar -C /my-portables/usr/bin -xzvf - k9s
chmod +x /my-portables/usr/bin/k9s

mkdir /my-portables/DEBIAN
cat <<EOF >/my-portables/DEBIAN/control
Package: my-portables
Version: 1.0
Section: unknown
Priority: optional
Depends: libc6
Architecture: amd64
Essential: no
Installed-Size: -1
Maintainer: Rkshvch <rokashevich@gmail.com>
Description: Portable things I usually need on my desktop
EOF
