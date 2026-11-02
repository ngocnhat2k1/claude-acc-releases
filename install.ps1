# Cài Claude Switcher cho Windows: app khay (ClaudeSwitcher.exe) và dòng lệnh (claude-acc.exe) để đổi acc Claude Code.
# Chạy trong PowerShell (không cần quyền admin):
#   [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; irm https://raw.githubusercontent.com/ngocnhat2k1/claude-acc-releases/main/install.ps1 | iex
# Cài vào %LOCALAPPDATA%\ClaudeAcc\bin, thêm thư mục đó vào PATH, tạo lối tắt Start Menu, bật mở cùng Windows rồi mở app.
# Chạy lại lệnh trên bất cứ lúc nào để cài lại bản mới nhất. Kho acc đã lưu không bị đụng tới.
& {
  $ErrorActionPreference = 'Stop'
  $ProgressPreference = 'SilentlyContinue'
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

  $release = 'https://github.com/ngocnhat2k1/claude-acc-releases/releases/download/'
  $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') { 'arm64' } else { 'amd64' }

  # File mô tả có chữ ký: payload là JSON (bản mới nhất, đường tải, SHA-256 của từng file .exe).
  # PowerShell không kiểm được chữ ký Ed25519, nên lần cài đầu dựa vào HTTPS và SHA-256.
  # Từ lần cập nhật sau, chính app kiểm chữ ký trước khi nhận bản mới.
  # Đọc qua API của GitHub, không qua raw.githubusercontent.com: CDN của nó có lúc giữ bản cũ nhiều phút.
  $r = Invoke-WebRequest 'https://api.github.com/repos/ngocnhat2k1/claude-acc-releases/contents/windows/latest.json?ref=main' -UseBasicParsing -Headers @{ Accept = 'application/vnd.github.raw'; 'User-Agent' = 'claude-acc-install' }
  $text = if ($r.Content -is [byte[]]) { [Text.Encoding]::UTF8.GetString($r.Content) } else { $r.Content }
  $latest = $text | ConvertFrom-Json
  $manifest = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($latest.payload)) | ConvertFrom-Json

  $dir = Join-Path $env:LOCALAPPDATA 'ClaudeAcc\bin'
  New-Item -ItemType Directory -Force -Path $dir | Out-Null

  # Tải một file, kiểm tiền tố đường tải và SHA-256, rồi đặt vào $dir\$name. Windows cho đổi tên file .exe đang
  # chạy: bản cũ thành .old (app tự xoá ở lần chạy sau). Bản .old trước đó còn bị giữ thì đặt tên khác. Đặt bản mới
  # hỏng (vd phần mềm diệt virus đang giữ file) thì trả bản cũ về chỗ cũ.
  function Install-File($asset, $name) {
    if (-not $asset.url.StartsWith($release)) { throw "Đường tải không thuộc repo phát hành, đã huỷ cài." }
    $exe = Join-Path $dir $name
    $tmp = "$exe.download"
    Invoke-WebRequest -Uri $asset.url -OutFile $tmp -UseBasicParsing
    if ((Get-FileHash -Path $tmp -Algorithm SHA256).Hash -ne $asset.sha256) {
      Remove-Item $tmp
      throw "Mã SHA-256 của $name không khớp, đã huỷ cài."
    }
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
    $exe
  }

  $cli = $manifest.assets.$arch
  if (-not $cli) { throw "Bản $($manifest.version) chưa có cho máy $arch." }
  $cliExe = Install-File $cli 'claude-acc.exe'

  # App khay có từ bản 0.2.0. Đang chạy thì tắt đúng bản trong thư mục cài, để mở lại bằng bản mới.
  $appExe = $null
  if ($manifest.app -and $manifest.app.$arch) {
    $target = Join-Path $dir 'ClaudeSwitcher.exe'
    Get-Process -Name 'ClaudeSwitcher' -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $target } | Stop-Process -Force -ErrorAction SilentlyContinue
    $appExe = Install-File $manifest.app.$arch 'ClaudeSwitcher.exe'
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

  & $cliExe version
  if ($appExe) {
    # Lối tắt Start Menu, mở cùng Windows (tắt được trong phần cài đặt của app), rồi mở app.
    $lnk = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Claude Switcher.lnk'
    $sc = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
    $sc.TargetPath = $appExe
    $sc.WorkingDirectory = $dir
    $sc.Description = 'Claude Switcher'
    $sc.Save()
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Claude Switcher' -Value "`"$appExe`""
    Start-Process -FilePath $appExe
    Write-Host "Đã cài Claude Switcher $($manifest.version) vào $dir."
    Write-Host "App đang chạy ở khay hệ thống (góc phải thanh tác vụ; không thấy thì bấm dấu ^). Mở lại bằng Start Menu → Claude Switcher."
    Write-Host "Dòng lệnh: claude-acc   (cửa sổ PowerShell khác thì mở lại để nhận PATH mới)"
  } else {
    Write-Host "Đã cài Claude Acc vào $dir. App tự cập nhật mỗi ngày khi bạn dùng."
    Write-Host "Thử ngay: claude-acc doctor   (cửa sổ PowerShell khác thì mở lại để nhận PATH mới)"
  }
}
