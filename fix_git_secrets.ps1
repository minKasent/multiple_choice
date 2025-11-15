# Script để xóa secrets khỏi git history
# Chạy script này trong PowerShell

Write-Host "Đang xóa các file chứa secrets khỏi git tracking..." -ForegroundColor Yellow

# Xóa file application-dev.yml khỏi git tracking (nhưng giữ lại file local)
git rm --cached backend/backend/src/main/resources/application-dev.yml

# Xóa thư mục logs khỏi git tracking
git rm -r --cached backend/backend/logs/

Write-Host "Đã xóa các file khỏi git tracking." -ForegroundColor Green
Write-Host ""
Write-Host "Bước tiếp theo:" -ForegroundColor Cyan
Write-Host "1. Commit các thay đổi: git add .gitignore backend/backend/.gitignore backend/backend/src/main/resources/application-dev.yml.example" -ForegroundColor White
Write-Host "2. Commit: git commit -m 'Remove secrets from git tracking and add .gitignore'" -ForegroundColor White
Write-Host "3. Push lại: git push -u origin main" -ForegroundColor White
Write-Host ""
Write-Host "Lưu ý: Nếu vẫn bị lỗi, bạn cần xóa secrets khỏi git history bằng cách:" -ForegroundColor Yellow
Write-Host "   git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch backend/backend/src/main/resources/application-dev.yml backend/backend/logs/*' --prune-empty --tag-name-filter cat -- --all" -ForegroundColor White

