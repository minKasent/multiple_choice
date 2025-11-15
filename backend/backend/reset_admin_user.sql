-- Script để reset tài khoản admin mặc định
-- Email: admin@gmail.com
-- Password: 123456 (đã hash bằng BCrypt)

-- Xóa user admin cũ nếu tồn tại
DELETE FROM users WHERE email = 'admin@gmail.com' OR username = 'admin';

-- Tạo lại user admin với thông tin mới
-- Password hash của "123456" với BCrypt: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
INSERT INTO users (
    username, 
    email, 
    password_hash, 
    full_name, 
    provider, 
    is_active, 
    is_verified,
    role_id,
    created_at,
    updated_at
) 
SELECT 
    'admin',
    'admin@gmail.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'Administrator',
    'local',
    true,
    true,
    id,
    NOW(),
    NOW()
FROM roles WHERE name = 'ADMIN';

-- Kiểm tra kết quả
SELECT 
    id, 
    username, 
    email, 
    full_name,
    is_active, 
    is_verified,
    (SELECT name FROM roles WHERE id = users.role_id) as role
FROM users
WHERE email = 'admin@gmail.com';

