import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';

class UserItem extends StatelessWidget {
  final String fullName;
  final String email;
  final String role;
  final String? studentCode;
  final String? teacherCode;
  final String? phone;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const UserItem({
    super.key,
    required this.fullName,
    required this.email,
    required this.role,
    this.studentCode,
    this.teacherCode,
    this.phone,
    required this.isActive,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  Color _getRoleColor() {
    switch (role) {
      case 'ADMIN':
        return AppColors.adminColor;
      case 'TEACHER':
        return AppColors.teacherColor;
      case 'PROCTOR':
        return AppColors.proctorColor;
      case 'STUDENT':
        return AppColors.studentColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getRoleLabel() {
    switch (role) {
      case 'ADMIN':
        return 'Admin';
      case 'TEACHER':
        return 'Giáo viên';
      case 'PROCTOR':
        return 'Giám thị';
      case 'STUDENT':
        return 'Sinh viên';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: roleColor.withValues(alpha: 0.2),
                child: Text(
                  fullName.initials,
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: context.textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getRoleLabel(),
                            style: TextStyle(
                              fontSize: 10,
                              color: roleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            style: context.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (studentCode != null || teacherCode != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            studentCode ?? teacherCode ?? '',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.statusSuccess.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isActive ? 'Hoạt động' : 'Vô hiệu hóa',
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive ? AppColors.statusSuccess : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              if (onEdit != null || onDelete != null || onToggleStatus != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'toggle':
                        onToggleStatus?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Sửa'),
                          ],
                        ),
                      ),
                    if (onToggleStatus != null)
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              isActive ? Icons.block : Icons.check_circle,
                              size: 20,
                              color: isActive ? AppColors.error : AppColors.statusSuccess,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
                              style: TextStyle(
                                color: isActive ? AppColors.error : AppColors.statusSuccess,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

