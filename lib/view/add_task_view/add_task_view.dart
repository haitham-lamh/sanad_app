import 'package:flutter/material.dart';
import 'package:sanad_app/view/add_task_view/add_task_form.dart';

class AddTaskView extends StatelessWidget {
  const AddTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [AddTaskForm()]));
  }
}