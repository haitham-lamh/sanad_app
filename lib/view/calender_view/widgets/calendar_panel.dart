import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:sanad_app/config/app_theme.dart';
import 'package:sanad_app/model/task_model.dart';

typedef DayTaskLoader = List<Task> Function(DateTime day);
typedef DaySelectedCallback = void Function(DateTime selectedDay, DateTime focusedDay);

class CalendarPanel extends StatelessWidget {
  const CalendarPanel({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.tasksForDay,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DaySelectedCallback onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final DayTaskLoader tasksForDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar<Task>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: CalendarFormat.month,
        headerVisible: false,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
          weekdayStyle: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(
            color: AppTheme.getTextPrimaryColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          weekendTextStyle: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.symmetric(vertical: 6),
        ),
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        eventLoader: tasksForDay,
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            final text = DateFormat.E('ar').format(day)[0];
            return Center(
              child: Text(
                text,
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            final isSunday = day.weekday == DateTime.sunday;
            return Center(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSunday ? Colors.redAccent : AppTheme.getTextPrimaryColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return Center(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return Center(
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          },
          markerBuilder: (context, day, events) {
            final dots = tasksForDay(day);
            if (dots.isEmpty) return const SizedBox.shrink();
            return const Positioned(
              bottom: 6,
              child: SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
