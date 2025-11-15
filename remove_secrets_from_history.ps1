# Script để xóa secrets khỏi git history hoàn toàn
# CẢNH BÁO: Script này sẽ rewrite git history. Chỉ chạy nếu bạn chắc chắn!

Write-Host "CẢNH BÁO: Script này sẽ rewrite git history!" -ForegroundColor Red
Write-Host "Đảm bảo bạn đã backup code trước khi chạy!" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Bạn có chắc muốn tiếp tục? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Đã hủy." -ForegroundColor Yellow
    exit
}

Write-Host "Đang xóa secrets khỏi git history..." -ForegroundColor Cyan

# Xóa application-dev.yml khỏi toàn bộ lịch sử
git filter-branch --force --index-filter `
    "git rm --cached --ignore-unmatch backend/backend/src/main/resources/application-dev.yml" `
    --prune-empty --tag-name-filter cat -- --all

# Xóa logs khỏi toàn bộ lịch sử
git filter-branch --force --index-filter `
    "git rm -r --cached --ignore-unmatch backend/backend/logs/" `
    --prune-empty --tag-name-filter cat -- --all

Write-Host ""
Write-Host "Đã xóa secrets khỏi git history!" -ForegroundColor Green
Write-Host ""
Write-Host "Bước tiếp theo:" -ForegroundColor Cyan
Write-Host "1. Force push: git push origin --force --all" -ForegroundColor White
Write-Host "2. Force push tags: git push origin --force --tags" -ForegroundColor White
Write-Host ""
Write-Host "LƯU Ý: Force push sẽ ghi đè lịch sử trên remote. Chỉ làm nếu bạn là người duy nhất làm việc với repo này!" -ForegroundColor Red

