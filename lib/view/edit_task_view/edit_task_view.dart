import 'package:flutter/material.dart';
import 'package:sanad_app/view/add_task_view/add_task_form.dart';
import 'package:sanad_app/view/widgets/custom_app_bar.dart';

class EditTaskView extends StatelessWidget {
  const EditTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0F172A),
      appBar: AppBar(
        flexibleSpace: CustomAppBar(
          userName: 'هيثم لمح',
          icon: Icons.menu,
          horPadding: 16,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'تعديل المهمة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: [
                Divider(
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFF726CC9),
                  height: 4,
                ),
                Divider(
                  indent: 32,
                  endIndent: 32,
                  color: Color(0xFF726CC9),
                  height: 4,
                ),
                Divider(
                  indent: 64,
                  endIndent: 64,
                  color: Color(0xFF726CC9),
                  height: 4,
                ),
                Divider(
                  indent: 100,
                  endIndent: 100,
                  color: Color(0xFF726CC9),
                  height: 4,
                ),
                Divider(
                  indent: 140,
                  endIndent: 140,
                  color: Color(0xFF726CC9),
                  height: 4,
                ),
                Divider(
                  indent: 170,
                  endIndent: 170,
                  color: Color(0xFF726CC9),
                  height: 4,
                ),
              ],
            ),

            SizedBox(height: 16),
            AddTaskForm(),
          ],
        ),
      ),
    );
  }
}
