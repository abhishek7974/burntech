import 'package:burntech/core/theme/theme_helper.dart';
import 'package:burntech/widget/custom_elevated_button.dart';
import 'package:burntech/widget/custom_text_form_field.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../controller/event_controller.dart';
import 'all_events_page.dart';
import 'create_evets_page.dart';

class SearchAndFilter extends ConsumerStatefulWidget {
  @override
  ConsumerState<SearchAndFilter> createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends ConsumerState<SearchAndFilter> {
  TextEditingController searchController = TextEditingController();
  bool isSearch = false;

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Search & Filter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final selectedFilters = await showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return FilterOptions(
                          onRemove: () {
                            ref.read(eventController).fetchEvents(
                                  eventType: selectedIndex == 0
                                      ? 'event'
                                      : selectedIndex == 1
                                          ? 'campaign'
                                          : 'art',
                                  isSearching: isSearch,
                                  searchQuery: searchController.text,
                                );
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                    if (selectedFilters != null) {
                      ref.read(eventController).getFilter(selectedFilters);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CupertinoIcons.slider_horizontal_3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            CustomTextFormField(
              controller: searchController,
              prefix: Icon(Icons.search, color: Colors.black54),
              hintText: 'Search...',
              onChange: (value) {
                print("searching balue == $value");
                setState(() {
                  isSearch = value.isNotEmpty;
                  print("isSearch ++  $isSearch");
                });

                ref.read(eventController).fetchEvents(
                      eventType: selectedIndex == 0
                          ? 'event'
                          : selectedIndex == 1
                              ? 'campaign'
                              : 'art',
                      isSearching: isSearch,
                      searchQuery: searchController.text,
                    );
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomSlidingSegmentedControl<int>(
                  initialValue: selectedIndex,
                  children: {
                    0: Text('Events'),
                    1: Text('Campaign'),
                    2: Text('Arts'),
                  },
                  decoration: BoxDecoration(
                    color: CupertinoColors.lightBackgroundGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.3),
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                        offset: Offset(0.0, 2.0),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInToLinear,
                  onValueChanged: (value) {
                    setState(() {
                      selectedIndex = value;
                    });

                    ref.read(eventController).fetchEvents(
                          eventType: selectedIndex == 0
                              ? 'events'
                              : selectedIndex == 1
                                  ? 'campaign'
                                  : 'art',
                          isSearching: isSearch,
                          searchQuery: searchController.text,
                        );
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: EventListPage(
                eventType: selectedIndex == 0
                    ? null
                    : selectedIndex == 1
                        ? 'campaign'
                        : 'art',
                isSearching: isSearch,
                searchQuery: searchController.text,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_horiz_outlined,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.art_track),
            label: "Art",
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return CreateEventsPage(
                  eventType: "art",
                );
              }));
            },
          ),

          SpeedDialChild(
            child: const Icon(Icons.cabin),
            label: 'Campaign',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return CreateEventsPage(
                  eventType: "campaign",
                );
              }));
            },
          ),
        ],
      ),
    );
  }
}

class FilterOptions extends StatefulWidget {
  Function()? onRemove;

  FilterOptions({this.onRemove, Key? key}) : super(key: key);

  @override
  _FilterOptionsState createState() => _FilterOptionsState();
}

class _FilterOptionsState extends State<FilterOptions> {
  final List<String> filters = [
    "Today",
    "Time",
    "Nearest",
    "Likes",
  ];

  List<String> selectedFilters = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter ....",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: const Text(
                    "clear all",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...filters.map((filter) {
              return CheckboxListTile(
                title: Text(filter),
                value: selectedFilters.contains(filter),
                onChanged: (isChecked) {
                  setState(() {
                    if (isChecked == true) {
                      selectedFilters.add(filter);
                    } else {
                      selectedFilters.remove(filter);
                    }
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 16),
            CustomElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedFilters); // Return selected filters
              },
              text: "Apply Filters",
            ),
          ],
        ),
      ),
    );
  }
}
