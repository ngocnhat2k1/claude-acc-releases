# Cài Claude Acc cho Windows: công cụ dòng lệnh đổi acc Claude Code.
# Chạy trong PowerShell (không cần quyền admin):
#   [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; irm https://raw.githubusercontent.com/ngocnhat2k1/claude-acc-releases/main/install.ps1 | iex
# Cài vào %LOCALAPPDATA%\ClaudeAcc\bin và thêm thư mục đó vào PATH.
# Chạy lại lệnh trên bất cứ lúc nào để cài lại bản mới nhất.
& {
  $ErrorActionPreference = 'Stop'
  $ProgressPreference = 'SilentlyContinue'
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

  $release = 'https://github.com/ngocnhat2k1/claude-acc-releases/releases/download/'
  $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') { 'arm64' } else { 'amd64' }

  # File mô tả có chữ ký: payload là JSON (bản mới nhất, đường tải, SHA-256 của từng file .exe).
  # PowerShell không kiểm được chữ ký Ed25519, nên lần cài đầu dựa vào HTTPS và SHA-256.
  # Từ lần cập nhật sau, chính app kiểm chữ ký trước khi nhận bản mới.
  $latest = Invoke-RestMethod "https://raw.githubusercontent.com/ngocnhat2k1/claude-acc-releases/main/windows/latest.json?t=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
  $manifest = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($latest.payload)) | ConvertFrom-Json
  $asset = $manifest.assets.$arch
  if (-not $asset) { throw "Bản $($manifest.version) chưa có cho máy $arch." }
  if (-not $asset.url.StartsWith($release)) { throw "Đường tải không thuộc repo phát hành, đã huỷ cài." }

  $dir = Join-Path $env:LOCALAPPDATA 'ClaudeAcc\bin'
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $exe = Join-Path $dir 'claude-acc.exe'
  $tmp = "$exe.download"
  Invoke-WebRequest -Uri $asset.url -OutFile $tmp -UseBasicParsing
  if ((Get-FileHash -Path $tmp -Algorithm SHA256).Hash -ne $asset.sha256) {
    Remove-Item $tmp
    throw "Mã SHA-256 của file tải về không khớp, đã huỷ cài."
  }

  # Windows cho đổi tên file .exe đang chạy: bản cũ thành .old (app tự xoá ở lần chạy sau). Bản .old
  # trước đó còn bị giữ thì đặt tên khác. Đặt bản mới hỏng (vd phần mềm diệt virus đang giữ file) thì
  # trả bản cũ về chỗ cũ.
  $old = $null
  if (Test-Path $exe) {
    $old = "$exe.old"
    if (Test-Path $old) {
      try { Remove-Item -Force $old } catch { $old = "$exe.old-$([DateTime]::UtcNow.Ticks)" }
    }
    Move-Item $exe $old
  }
  try {
    Move-Item $tmp $exe
  } catch {
    if ($old) { Move-Item $old $exe }
    throw
  }

  # Thêm vào PATH của user, giữ nguyên kiểu REG_EXPAND_SZ của giá trị cũ.
  $key = 'HKCU:\Environment'
  $path = (Get-Item $key).GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
  if (($path -split ';') -notcontains $dir) {
    $new = if ($path) { "$($path.TrimEnd(';'));$dir" } else { $dir }
    Set-ItemProperty -Path $key -Name Path -Value $new -Type ExpandString
    # Đặt rồi xoá một biến tạm để Windows báo cho các chương trình biết PATH vừa đổi.
    [Environment]::SetEnvironmentVariable('CLAUDE_ACC_INSTALL', '1', 'User')
    [Environment]::SetEnvironmentVariable('CLAUDE_ACC_INSTALL', $null, 'User')
  }
  if (($env:Path -split ';') -notcontains $dir) { $env:Path = "$env:Path;$dir" }

  & $exe version
  Write-Host "Đã cài Claude Acc vào $dir. App tự cập nhật mỗi ngày khi bạn dùng."
  Write-Host "Thử ngay: claude-acc doctor   (cửa sổ PowerShell khác thì mở lại để nhận PATH mới)"
}
