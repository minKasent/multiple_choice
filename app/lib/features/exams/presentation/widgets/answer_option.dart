import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';

class AnswerOption extends StatelessWidget {
  final int index;
  final String content;
  final bool isSelected;
  final VoidCallback onTap;
  final bool? isCorrect; // For review mode
  final bool showResult;

  const AnswerOption({
    super.key,
    required this.index,
    required this.content,
    required this.isSelected,
    required this.onTap,
    this.isCorrect,
    this.showResult = false,
  });

  String get _optionLabel {
    const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    return labels[index];
  }

  Color get _backgroundColor {
    if (showResult) {
      if (isCorrect == true) {
        return AppColors.statusSuccess.withValues(alpha: 0.1);
      } else if (isSelected && isCorrect == false) {
        return AppColors.error.withValues(alpha: 0.1);
      }
    }
    return isSelected
        ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.surface;
  }

  Color get _borderColor {
    if (showResult) {
      if (isCorrect == true) {
        return AppColors.statusSuccess;
      } else if (isSelected && isCorrect == false) {
        return AppColors.error;
      }
    }
    return isSelected ? AppColors.primary : AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: showResult ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _borderColor,
              width: isSelected || showResult ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Option label (A, B, C, D)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: showResult
                      ? (isCorrect == true
                          ? AppColors.statusSuccess
                          : isSelected && isCorrect == false
                              ? AppColors.error
                              : AppColors.textSecondary.withValues(alpha: 0.1))
                      : (isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.1)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _optionLabel,
                    style: TextStyle(
                      color: showResult
                          ? (isCorrect == true || (isSelected && isCorrect == false)
                              ? Colors.white
                              : AppColors.textSecondary)
                          : (isSelected
                              ? Colors.white
                              : AppColors.textSecondary),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Text(
                  content,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: showResult
                        ? (isCorrect == true
                            ? AppColors.statusSuccess
                            : isSelected && isCorrect == false
                                ? AppColors.error
                                : AppColors.textPrimary)
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              
              // Selection indicator
              if (isSelected && !showResult)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
              
              // Result indicator
              if (showResult) ...[
                if (isCorrect == true)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.statusSuccess,
                  )
                else if (isSelected && isCorrect == false)
                  const Icon(
                    Icons.cancel,
                    color: AppColors.error,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

