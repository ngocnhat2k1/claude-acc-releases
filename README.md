# Claude Acc: bản phát hành

Repo này chỉ chứa bản cài và file `appcast.xml` để app tự cập nhật. Mã nguồn để ở repo riêng.

## Cài lần đầu

1. Tải [ClaudeAcc.dmg](https://github.com/ngocnhat2k1/claude-acc-releases/releases/latest/download/ClaudeAcc.dmg). Chỉ chạy trên Mac chip Apple, macOS 13 trở lên.
2. Mở file dmg, kéo **Claude Acc** vào thư mục **Applications**.
3. Lần đầu mở, macOS chặn vì app chưa được Apple chứng nhận. Vào **Cài đặt hệ thống → Quyền riêng tư & Bảo mật**, kéo xuống và bấm **Vẫn mở**. Hoặc chạy `xattr -cr /Applications/"Claude Acc.app"` trong Terminal.

## Cập nhật

App tự kiểm tra bản mới mỗi ngày. Có bản mới thì macOS hiện thông báo và menu có nút **Cập nhật**. Bấm vào là app tự tải, cài và mở lại. Muốn kiểm tra ngay thì bấm **Kiểm tra bản mới** ở cuối menu.

Mỗi bản được ký bằng khoá EdDSA của người phát hành. App không cài bản nào có chữ ký không khớp.
