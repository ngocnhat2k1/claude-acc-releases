#!/bin/sh
# Cài Claude Switcher cho Linux: app khay (claude-switcher) và dòng lệnh (claude-acc) để đổi acc Claude Code.
#   curl -fsSL https://raw.githubusercontent.com/ngocnhat2k1/claude-acc-releases/main/install.sh | sh
# Cài vào ~/.local/bin. Máy có màn hình thì tạo lối tắt trong menu ứng dụng, bật mở cùng máy rồi mở app.
# Chạy lại lệnh trên để cài lại bản mới nhất. Kho acc đã lưu (~/.local/share/claude-acc) không bị đụng tới.
#
# File này nằm ở scripts/linux/install.sh của repo claude-acc-windows; release-linux.sh chép nó sang repo phát hành.
set -eu

release=https://github.com/ngocnhat2k1/claude-acc-releases/releases/download/
case "$(uname -m)" in
  x86_64 | amd64) arch=amd64 ;;
  aarch64 | arm64) arch=arm64 ;;
  *) echo "Chưa có bản cho máy $(uname -m)." >&2; exit 1 ;;
esac
for c in curl python3 sha256sum; do
  command -v "$c" >/dev/null || { echo "Cần lệnh $c để cài." >&2; exit 1; }
done

dir="$HOME/.local/bin"
mkdir -p "$dir"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# File mô tả có chữ ký: payload là JSON (bản mới nhất, đường tải, SHA-256 của từng file). Lần cài đầu dựa vào HTTPS
# và SHA-256; từ lần cập nhật sau, chính app kiểm chữ ký Ed25519 trước khi nhận bản mới. Đọc qua API của GitHub, không
# qua raw.githubusercontent.com: CDN của nó có lúc giữ bản cũ nhiều phút.
curl -fsSL -H 'Accept: application/vnd.github.raw' -H 'User-Agent: claude-acc-install' \
  'https://api.github.com/repos/ngocnhat2k1/claude-acc-releases/contents/linux/latest.json?ref=main' -o "$tmp/latest.json"
python3 - "$tmp/latest.json" "$arch" "$release" >"$tmp/files" <<'PY'
import base64, json, sys
path, arch, release = sys.argv[1:]
m = json.loads(base64.b64decode(json.load(open(path))["payload"]))
print(m["version"])
for key, name in (("assets", "claude-acc"), ("app", "claude-switcher")):
    f = (m.get(key) or {}).get(arch)
    if f:
        if not f["url"].startswith(release):
            sys.exit("Đường tải không thuộc repo phát hành, đã huỷ cài.")
        print(f["url"], f["sha256"], name)
PY
version=$(head -n 1 "$tmp/files")
grep -q ' claude-acc$' "$tmp/files" || { echo "Bản $version chưa có cho máy $arch." >&2; exit 1; }

# Tải và kiểm hết rồi mới thay: một file hỏng thì không file nào bị thay.
tail -n +2 "$tmp/files" | while read -r url sum name; do
  curl -fsSL "$url" -o "$tmp/$name"
  echo "$sum  $tmp/$name" | sha256sum -c --status || { echo "Mã SHA-256 của $name không khớp, đã huỷ cài." >&2; exit 1; }
  chmod 755 "$tmp/$name"
done
# App đang chạy thì tắt để mở lại bằng bản mới. Linux cho thay file đang chạy: bản cũ chạy tiếp tới khi thoát.
pkill -u "$(id -u)" -x claude-switcher 2>/dev/null || true
tail -n +2 "$tmp/files" | while read -r url sum name; do
  mv -f "$tmp/$name" "$dir/$name"
done
"$dir/claude-acc" version </dev/null

case ":$PATH:" in
  *":$dir:"*) ;;
  *) echo "Thêm $dir vào PATH để gõ claude-acc ở mọi nơi (Ubuntu tự thêm sau khi đăng nhập lại)." ;;
esac

[ -x "$dir/claude-switcher" ] || exit 0
missing=$(ldd "$dir/claude-switcher" 2>/dev/null | grep 'not found' || true)
if [ -n "$missing" ]; then
  echo "App khay cần GTK 3 và WebKitGTK 4.1. Ubuntu, Debian: sudo apt install libgtk-3-0 libwebkit2gtk-4.1-0"
  echo "Fedora: sudo dnf install gtk3 webkit2gtk4.1. Cài xong chạy: claude-acc app"
  exit 0
fi
if [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
  echo "Máy không có màn hình: dùng dòng lệnh claude-acc (gõ claude-acc help). Có màn hình thì mở app bằng: claude-acc app"
  exit 0
fi
"$dir/claude-acc" app </dev/null
