import 'package:flutter/material.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/model/task_model.dart';

class AnimatedTaskCard extends StatefulWidget {
  final TaskModel task;
  final AnimationController cardController;
  final AnimationController progressController;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    required this.cardController,
    required this.progressController,
    required this.isLast,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard> {
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: widget.cardController, curve: Curves.elasticOut),
      ),
      child: FadeTransition(
        opacity: widget.cardController,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardBackgroundColor(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.task.categoryColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.task.title,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getTextPrimaryColor(context),
                                      decoration: widget.task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.task.categoryColor.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          widget.task.category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: widget.task.categoryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.task.time,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.getTextSecondaryColor(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: AppTheme.getTextSecondaryColor(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: widget.task.categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.task.icon,
                                color: widget.task.categoryColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AnimatedBuilder(
                                  animation: widget.progressController,
                                  builder: (context, child) {
                                    return Text(
                                      '${(widget.progressController.value * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.task.categoryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  'الإنجاز',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.getTextSecondaryColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedBuilder(
                                  animation: widget.progressController,
                                  builder: (context, child) {
                                    return Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: widget.task.categoryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: widget.progressController.value,
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  widget.task.categoryColor,
                                                  widget.task.categoryColor.withOpacity(0.7),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: widget.task.categoryColor.withOpacity(0.4),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.task.duration,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.getTextSecondaryColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  GestureDetector(
                    onTap: widget.onTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.task.isCompleted
                            ? widget.task.categoryColor
                            : AppTheme.getCardBackgroundColor(context),
                        border: Border.all(color: widget.task.categoryColor, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: widget.task.categoryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: widget.task.isCompleted
                              ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ),
                  if (!widget.isLast)
                    Container(
                      width: 2,
                      height: 100,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            widget.task.categoryColor.withOpacity(0.5),
                            widget.task.categoryColor.withOpacity(0.1),
                          ],
                        ),
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
