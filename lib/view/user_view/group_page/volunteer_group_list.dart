
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burntech/controller/group_controller.dart';
import '../../../core/theme/theme_helper.dart';
import 'create_group.dart';
import 'widgets/group_card.dart';


class VolunteerGroupList extends ConsumerStatefulWidget {

  const VolunteerGroupList({Key? key}) : super(key: key);

  @override
  ConsumerState<VolunteerGroupList> createState() => _VolunteerGroupListState();
}

class _VolunteerGroupListState extends ConsumerState<VolunteerGroupList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      ref.read(groupControllerNotifier).fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupController = ref.watch(groupControllerNotifier);

    return Scaffold(
      appBar:  AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        title: const Text(
          'Volunteer Groups',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),

      body: groupController.groupList.isEmpty
          ? const Center(child: Text("Empty group list"))
          : ListView.builder(
              itemCount: groupController.groupList.length,
              itemBuilder: (context, index) {
                final group = groupController.groupList[index];
                return GroupCard(groupData: group);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return CreateGroupPage();
          }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


