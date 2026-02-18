import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/model/task_model.dart';
import 'package:sanad_app/utils/task_model_utils.dart';

class CalendarTaskItem extends StatelessWidget {
  const CalendarTaskItem({
    super.key,
    required this.task,
    this.highlight = false,
  });

  final Task task;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final TaskModel model = convertTaskToModel(task);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              highlight
                  ? model.categoryColor.withOpacity(0.7)
                  : AppTheme.getBorderColor(context),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                model.category,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: model.categoryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                model.time,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  model.title,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppTheme.getTextPrimaryColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: model.categoryColor.withOpacity(0.2),
                child: Icon(model.icon, color: model.categoryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: model.progress,
              minHeight: 6,
              color: model.categoryColor,
              backgroundColor: model.categoryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
