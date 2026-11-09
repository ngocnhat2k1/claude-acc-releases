# Claude Switcher: bản phát hành

Claude Switcher (tên cũ Claude Acc) đổi acc Claude Code. Repo này chỉ chứa bản cài và các file để app tự cập nhật, cho macOS, Windows và Linux. Mã nguồn để ở repo riêng.

## macOS

### Cài lần đầu

1. Tải [ClaudeAcc.dmg](https://github.com/ngocnhat2k1/claude-acc-releases/releases/download/mac/ClaudeAcc.dmg). Chỉ chạy trên Mac chip Apple, macOS 13 trở lên.
2. Mở file dmg, kéo **Claude Switcher** vào thư mục **Applications**.
3. Lần đầu mở, macOS chặn vì app chưa được Apple chứng nhận. Vào **Cài đặt hệ thống → Quyền riêng tư & Bảo mật**, kéo xuống và bấm **Vẫn mở**. Hoặc chạy `xattr -cr /Applications/"Claude Switcher.app"` trong Terminal.

### Cập nhật

App tự kiểm tra bản mới 5 phút một lần và mỗi khi mở menu (từ bản 1.2.3; bản cũ hơn mỗi ngày một lần). Có bản mới thì macOS hiện thông báo và menu có nút **Cập nhật**. Bấm vào là app tự tải, cài và mở lại. Muốn kiểm tra ngay thì bấm **Kiểm tra bản mới** ở cuối menu.

Mỗi bản được ký bằng khoá EdDSA của người phát hành. App không cài bản nào có chữ ký không khớp.

## Windows

Claude Switcher cho Windows gồm hai phần, cài cùng một lệnh:
- **App khay** `ClaudeSwitcher.exe`: icon vòng tròn ở góc phải thanh tác vụ, đổi màu theo hạn mức đang dùng. Bấm vào là hiện bảng, giao diện giống bản Mac.
- **Dòng lệnh** `claude-acc`: làm được mọi việc như app, và có thêm lệnh `doctor` để kiểm tra máy.

App làm được:
- **Đổi acc** bằng một cú bấm, không phải đăng nhập lại.
- **Thêm acc:** app tự mở trình duyệt để bạn đăng nhập.
- **Xem hạn mức** 5 giờ, tuần và Fable của từng acc, kèm giờ reset.
- **Tự đổi acc** khi acc đang dùng chạm 95%, theo thứ tự ưu tiên bạn tự xếp: số nhỏ ở góc thẻ acc, chuột phải vào thẻ rồi chọn **Ưu tiên** để đổi. Tắt được bằng công tắc "Tự đổi".
- **Chọn Model và Effort** mặc định cho Claude Code.
- **API key dự phòng:** dùng khi mọi acc đều hết hạn mức, có ước tính chi phí.
- **Đổi luôn cả WSL:** bản WSL nào bật "Dùng chung đăng nhập với Windows" trong phần cài đặt thì đổi theo Windows.

### Cài

Mở PowerShell (không cần quyền admin), dán dòng này rồi Enter:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; irm https://raw.githubusercontent.com/ngocnhat2k1/claude-acc-releases/main/install.ps1 | iex
```

Lệnh này:

1. Tải bản hợp với máy (x64 hoặc ARM64) của cả app lẫn dòng lệnh vào `%LOCALAPPDATA%\ClaudeAcc\bin`, và kiểm mã SHA-256 của từng file.
2. Thêm thư mục đó vào PATH.
3. Tạo lối tắt **Claude Switcher** trong Start Menu và bật mở cùng Windows.
4. Mở app.

Icon nằm ở góc phải thanh tác vụ. Không thấy thì bấm dấu **^** và kéo icon ra ngoài.

Cài lại thì chạy lại đúng lệnh trên. Các acc đã lưu vẫn còn.

### Cập nhật

- **App:** tự kiểm tra bản mới 5 phút một lần và mỗi khi mở bảng. Có bản mới thì Windows hiện thông báo, và bảng có nút **Cập nhật**. Bấm vào là app tự tải, thay file rồi mở lại.
- **Dòng lệnh:** tự cập nhật mỗi ngày một lần. Muốn cập nhật ngay thì chạy `claude-acc update`.
- **Máy đang có bản dòng lệnh 0.1.x:** tự lên bản mới. Ở lần chạy `claude-acc` kế tiếp, nó tải app về, tạo lối tắt Start Menu và mở app. Muốn có ngay thì chạy `claude-acc update` hai lần: lần đầu lên bản mới, lần sau tải app.

Mỗi bản có file mô tả `windows/latest.json` kèm chữ ký Ed25519. App chỉ nhận bản đúng chữ ký, đúng mã SHA-256, và có số phiên bản cao hơn bản đang chạy.

### Gỡ

1. Thoát app: bấm chuột phải vào icon, chọn **Thoát**.
2. Xoá thư mục `%LOCALAPPDATA%\ClaudeAcc` và lối tắt Start Menu **Claude Switcher**.
3. Bỏ `%LOCALAPPDATA%\ClaudeAcc\bin` khỏi PATH của user (Cài đặt → Hệ thống → Giới thiệu → Cài đặt hệ thống nâng cao → Biến môi trường).
4. Xoá giá trị **Claude Switcher** trong Task Manager → Startup apps (hoặc tắt "Mở cùng Windows" trong app trước khi thoát).

Lưu ý: thư mục `%LOCALAPPDATA%\ClaudeAcc` còn chứa kho acc và API key đã lưu. Xoá nó là mất các acc đã lưu, và phải đăng nhập lại.

## Linux

Claude Switcher cho Linux có hai phần như bản Windows, cài cùng một lệnh:
- **App khay** `claude-switcher`: icon vòng tròn trên thanh trên cùng, đổi màu theo hạn mức đang dùng. Bấm vào là hiện bảng.
- **Dòng lệnh** `claude-acc`: làm được mọi việc như app, và có thêm lệnh `doctor` để kiểm tra máy.

App làm được như bản Windows, trừ phần WSL.

### Cài

Mở Terminal, dán dòng này rồi Enter:

```sh
curl -fsSL https://raw.githubusercontent.com/ngocnhat2k1/claude-acc-releases/main/install.sh | sh
```

Lệnh này:

1. Tải app và dòng lệnh vào `~/.local/bin`, rồi kiểm mã SHA-256 của từng file. App khay chỉ có cho máy x64. Máy ARM64 chỉ có dòng lệnh.
2. Máy có màn hình: tạo lối tắt **Claude Switcher** trong menu ứng dụng, bật mở cùng máy rồi mở app.
3. Máy không có màn hình (máy chủ, WSL): chỉ cài dòng lệnh. Gõ `claude-acc help` để xem các lệnh.

Cần bản Linux có glibc 2.35 trở lên, vd Ubuntu 22.04 hay Debian 12 trở lên. App khay cần thêm GTK 3 và WebKitGTK 4.1. Máy thiếu thì lệnh cài in sẵn lệnh cài thêm (Ubuntu, Debian: `sudo apt install libgtk-3-0 libwebkit2gtk-4.1-0`), cài xong chạy `claude-acc app`.

Icon nằm trên thanh trên cùng: Ubuntu, KDE, Xfce hiện sẵn. Các bản khác dùng GNOME (vd Fedora) thì cần cài extension **AppIndicator and KStatusNotifierItem Support**.

Cài lại thì chạy lại đúng lệnh trên. Các acc đã lưu vẫn còn.

### Cập nhật

App và dòng lệnh tự cập nhật như bản Windows. Muốn cập nhật ngay thì chạy `claude-acc update`.

Mỗi bản có file mô tả `linux/latest.json` kèm chữ ký Ed25519, cùng khoá với bản Windows. App chỉ nhận bản đúng chữ ký, đúng mã SHA-256, và có số phiên bản cao hơn bản đang chạy.

### Gỡ

1. Thoát app: bấm chuột phải vào icon, chọn **Thoát**.
2. Xoá các file đã cài:

   ```sh
   rm -f ~/.local/bin/claude-acc ~/.local/bin/claude-switcher ~/.config/autostart/claude-switcher.desktop \
     ~/.local/share/applications/claude-switcher.desktop ~/.local/share/icons/hicolor/256x256/apps/claude-switcher.png
   ```

Lưu ý: thư mục `~/.local/share/claude-acc` chứa kho acc và API key đã lưu. Chỉ user của bạn đọc được (quyền 600), giống cách Claude Code lưu đăng nhập trên Linux, nhưng không mã hoá. Xoá thư mục đó là mất các acc đã lưu, và phải đăng nhập lại.
