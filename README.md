# Claude Switcher: bản phát hành

Claude Switcher (tên cũ Claude Acc) đổi acc Claude Code. Repo này chỉ chứa bản cài và các file để app tự cập nhật, cho cả macOS lẫn Windows. Mã nguồn để ở repo riêng.

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
- **Xem hạn mức** 5 giờ, tuần và Fable của từng acc.
- **Tự đổi acc** khi acc đang dùng chạm 95%. Tắt được bằng chip "Tự đổi".
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
