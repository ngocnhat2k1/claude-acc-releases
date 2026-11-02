# Claude Switcher: bản phát hành

Claude Switcher (tên cũ Claude Acc) đổi acc Claude Code. Repo này chỉ chứa bản cài và các file để app tự cập nhật, cho cả macOS lẫn Windows. Mã nguồn để ở repo riêng.

## macOS

### Cài lần đầu

1. Tải [ClaudeAcc.dmg](https://github.com/ngocnhat2k1/claude-acc-releases/releases/download/mac/ClaudeAcc.dmg). Chỉ chạy trên Mac chip Apple, macOS 13 trở lên.
2. Mở file dmg, kéo **Claude Switcher** vào thư mục **Applications**.
3. Lần đầu mở, macOS chặn vì app chưa được Apple chứng nhận. Vào **Cài đặt hệ thống → Quyền riêng tư & Bảo mật**, kéo xuống và bấm **Vẫn mở**. Hoặc chạy `xattr -cr /Applications/"Claude Switcher.app"` trong Terminal.

### Cập nhật

App tự kiểm tra bản mới mỗi ngày. Có bản mới thì macOS hiện thông báo và menu có nút **Cập nhật**. Bấm vào là app tự tải, cài và mở lại. Muốn kiểm tra ngay thì bấm **Kiểm tra bản mới** ở cuối menu.

Mỗi bản được ký bằng khoá EdDSA của người phát hành. App không cài bản nào có chữ ký không khớp.

## Windows

Bản Windows hiện là công cụ dòng lệnh `claude-acc`. Nó đổi acc Claude Code, thêm acc, xem hạn mức và có lệnh `doctor`. App ở khay hệ thống sẽ có sau, và tự về máy qua cập nhật.

### Cài

Mở PowerShell (không cần quyền admin), dán dòng này rồi Enter:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; irm https://raw.githubusercontent.com/ngocnhat2k1/claude-acc-releases/main/install.ps1 | iex
```

Lệnh này làm ba việc:

1. Tải bản hợp với máy (x64 hoặc ARM64) vào `%LOCALAPPDATA%\ClaudeAcc\bin`, rồi kiểm mã SHA-256 của file.
2. Thêm thư mục đó vào PATH.
3. In số phiên bản.

Sau đó gõ `claude-acc doctor` để kiểm tra máy, và `claude-acc` để xem các lệnh.

### Cập nhật

Mỗi ngày một lần, sau khi bạn chạy một lệnh `claude-acc` bất kỳ, app tự kiểm tra bản mới. Có bản mới thì app tải về và thay, lần chạy sau dùng bản mới. Muốn cập nhật ngay thì chạy `claude-acc update`.

Mỗi bản có file mô tả `windows/latest.json` kèm chữ ký Ed25519. App chỉ nhận bản đúng chữ ký, đúng mã SHA-256, và có số phiên bản cao hơn bản đang chạy.

### Gỡ

Xoá thư mục `%LOCALAPPDATA%\ClaudeAcc`, rồi bỏ `%LOCALAPPDATA%\ClaudeAcc\bin` khỏi PATH của user (Cài đặt → Hệ thống → Giới thiệu → Cài đặt hệ thống nâng cao → Biến môi trường).

Lưu ý: thư mục `%LOCALAPPDATA%\ClaudeAcc` còn chứa kho acc đã lưu. Xoá nó là mất các acc đã lưu, và phải `/login` lại.
