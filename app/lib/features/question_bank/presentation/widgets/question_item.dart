import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';

class QuestionItem extends StatelessWidget {
  final String content;
  final String type;
  final String difficulty;
  final int answerCount;
  final String subject;
  final String chapter;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QuestionItem({
    super.key,
    required this.content,
    required this.type,
    required this.difficulty,
    required this.answerCount,
    required this.subject,
    required this.chapter,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getDifficultyColor() {
    switch (difficulty) {
      case 'EASY':
        return AppColors.statusSuccess;
      case 'MEDIUM':
        return AppColors.warning;
      case 'HARD':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getDifficultyLabel() {
    switch (difficulty) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'TB';
      case 'HARD':
        return 'Khó';
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      content,
                      style: context.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
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
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Type
                  _Chip(
                    icon: Icons.quiz,
                    label: type == 'MULTIPLE_CHOICE' ? 'Trắc nghiệm' : 'Điền khuyết',
                    color: AppColors.info,
                  ),
                  
                  // Difficulty
                  _Chip(
                    icon: Icons.speed,
                    label: _getDifficultyLabel(),
                    color: difficultyColor,
                  ),
                  
                  // Answer count
                  _Chip(
                    icon: Icons.format_list_numbered,
                    label: '$answerCount đáp án',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.book, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    subject,
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.menu_book, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    chapter,
                    style: context.textTheme.bodySmall,
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

