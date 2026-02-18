import 'package:flutter/material.dart';
import 'package:sanad_app/model/drawer_item_model.dart';
import 'package:sanad_app/view/widgets/custom_drawer_item.dart';

class CustomDrawerItemsListView extends StatelessWidget {
  const CustomDrawerItemsListView({super.key, required this.items});

  final List<DrawerItemModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return CustomDrawerItem(drawerItemModel: items[index]);
      },
    );
  }
}
