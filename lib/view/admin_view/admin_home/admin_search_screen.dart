import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controller/event_controller.dart';
import '../../../controller/search_controller.dart';
import '../../../core/firebase_constant/firebase_constants.dart';
import '../../../core/theme/theme_helper.dart';
import '../../../core/utils_constants/utils_constants.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/custom_image.dart';
import '../../../widget/custom_text_form_field.dart';
import '../../user_view/events_page/events_detail_page.dart';
import '../admin_event/edit_admin_event.dart';

class SearchScreenAdmin extends ConsumerStatefulWidget {
  @override
  ConsumerState<SearchScreenAdmin> createState() => _SearchScreenAdminState();
}

class _SearchScreenAdminState extends ConsumerState<SearchScreenAdmin> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Automatically focus on search input
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(searchFocusNode);
    });

    // Load all locations when the screen is initialized
    ref.read(searchControllerProvider).loadAllLocations();
  }

  @override
  Widget build(BuildContext context) {
    final searchControllerNotifier = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: CustomTextFormField(
            onChange: (query) {
              print("quey ++  ${query}");
              ref.read(searchControllerProvider).searchLocations(query);
            },
            prefix: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_rounded,
              ),
            ),
            suffix: Icon(Icons.search),
            fillColor: Colors.grey.shade100,
            filled: true,
            hintText: "Search events, locations...",
            controller: searchController,
          ),
        ),
      ),
      body: searchControllerNotifier.filteredLocations.isEmpty
          ? Center(
        child: Text(
          'No results found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: searchControllerNotifier.filteredLocations.length,
        itemBuilder: (context, index) {
          final location =
          searchControllerNotifier.filteredLocations[index];
          return ListTile(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return EventDetailPage(
                  eventId: location['id'],
                  eventType: location["events_type"],
                );
              }));
            },
            leading: CustomImageView(
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                imagePath: location['image_url']),
            title: Text(location['title'] ?? 'Unknown Event'),
            subtitle: Text(location['description'] ?? 'No description'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(30)),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) {
                          return EditAdminEvent(eventId: location['id']);
                        }));
                      },
                      child: Icon(Icons.edit, color: Colors.white,size: 12,)),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: theme.primaryColor,
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(30)),
                  child: GestureDetector(
                      onTap: () {
                        try {
                          FirebaseConstants.firestore
                              .collection("events")
                              .doc(location['id'])
                              .delete();
                          ref.read(eventController).fetchEvents(
                            eventType: "events",
                            searchQuery: "",
                            isSearching: false,
                          );
                          UtilsConstant.showSnackbarSuccess(
                              "Deleted successfull", );
                        } catch (e) {
                          UtilsConstant.showSnackbarError(
                              "Something went wronf $e");
                        }
                      },
                      child: Icon(Icons.delete, color: Colors.white,size: 10,)),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}