import 'package:burntech/core/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controller/search_controller.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/custom_image.dart';
import '../../../widget/custom_text_form_field.dart';
import '../events_page/events_detail_page.dart'; // Import the SearchController and provider

class SearchScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
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
                );
              },
            ),
    );
  }
}
