import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/view/widgets/custom_button.dart';

class TaskDetailsView extends StatelessWidget {
  const TaskDetailsView({
    super.key,
    required this.task,
    this.onEdit,
    this.onDelete,
  });

  final TaskModel task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.getTextPrimaryColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'تفاصيل المهمة',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: task.categoryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: task.categoryColor.withOpacity(0.2),
                    child: Icon(
                      task.icon,
                      size: 50,
                      color: task.categoryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    task.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.getTextPrimaryColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: task.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: task.categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      task.category,
                      style: TextStyle(
                        color: task.categoryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
    
            _buildSection(
              context: context,
              title: 'مستوى الإنجاز',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(task.progress * 100).toInt()}%',
                        style: TextStyle(
                          color: task.categoryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'الإنجاز',
                        style: TextStyle(
                          color: AppTheme.getTextSecondaryColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: task.progress,
                      minHeight: 12,
                      backgroundColor: task.categoryColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(task.categoryColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
    
            if (task.desc != null && task.desc!.isNotEmpty)
              _buildSection(
                context: context,
                title: 'الوصف',
                child: Text(
                  task.desc!,
                  style: TextStyle(
                    color: AppTheme.getTextSecondaryColor(context),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            if (task.desc != null && task.desc!.isNotEmpty)
              const SizedBox(height: 20),
    
            _buildSection(
              context: context,
              title: 'التاريخ والوقت',
              child: Column(
                children: [
                  _buildInfoRow(
                    context: context,
                    icon: Icons.calendar_today_rounded,
                    label: 'التاريخ',
                    value: _formatDate(task.date),
                    color: task.categoryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context: context,
                    icon: Icons.access_time_rounded,
                    label: 'الوقت',
                    value: task.time,
                    color: task.categoryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
    
            _buildSection(
              context: context,
              title: 'التكرار',
              child: _buildInfoRow(
                context: context,
                icon: Icons.repeat_rounded,
                label: 'الفترة',
                value: task.duration,
                color: task.categoryColor,
              ),
            ),
            const SizedBox(height: 20),
    
            _buildSection(
              context: context,
              title: 'الحالة',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: task.isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      task.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      color: task.isCompleted ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                    Text(
                      task.isCompleted ? 'مكتملة' : 'قيد التنفيذ',
                      style: TextStyle(
                        color: task.isCompleted ? Colors.green : Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
    
            if (onEdit != null || onDelete != null)
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: CustomButton(
                        text: 'تعديل',
                        onTap: () {
                          Navigator.pop(context);
                          onEdit?.call();
                        },
                      ),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: 12),
                  if (onDelete != null)
                    Expanded(
                      child: CustomButton(
                        text: 'حذف',
                        onTap: () => _showDeleteConfirmation(context),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 6,
                backgroundColor: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.getTextPrimaryColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getTextSecondaryColor(context),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'غير محدد';
    try {
      final parsed = DateTime.tryParse(date.split(' ').first);
      if (parsed == null) return date;
      return DateFormat.yMMMMd('ar').format(parsed);
    } catch (e) {
      return date;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تأكيد الحذف',
                  style: TextStyle(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف هذه المهمة؟\nلا يمكن التراجع عن هذا الإجراء.',
            style: TextStyle(
              color: AppTheme.getTextSecondaryColor(context),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: AppTheme.getTextSecondaryColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // إغلاق dialog
                Navigator.pop(context); // إغلاق صفحة التفاصيل
                onDelete?.call(); // حذف المهمة
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'حذف',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
