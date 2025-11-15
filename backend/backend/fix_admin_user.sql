-- Script để sửa hoặc tạo lại user admin

-- Cập nhật user admin nếu đã tồn tại
UPDATE users
SET is_active = true,
    is_verified = true,
    password_hash = '$2a$10$9vqYqGqZ8xGQQQQQQQQQQeJZKx.x.x.x.x.x.x.x.x.x.x' -- Sẽ được cập nhật khi restart app
WHERE email = 'admin@exam.com' OR username = 'admin';

-- Nếu muốn xóa và tạo lại hoàn toàn (uncomment dòng dưới)
-- DELETE FROM users WHERE email = 'admin@exam.com' OR username = 'admin';

-- Kiểm tra user admin
SELECT id, username, email, is_active, is_verified, full_name
FROM users
WHERE email = 'admin@exam.com' OR username = 'admin';

