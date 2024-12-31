import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controller/event_controller.dart';
import 'widget/events_card.dart';

class EventListPage extends ConsumerStatefulWidget {
  final String? eventType;
  final String? searchQuery;
  final bool isSearching;

  EventListPage({
    this.eventType,
    required this.isSearching,
    this.searchQuery,
  });

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends ConsumerState<EventListPage> {
  @override
  void initState() {
    super.initState();

    // Trigger fetch when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventController).fetchEvents(
        eventType: widget.eventType,
        searchQuery: widget.searchQuery,
        isSearching: widget.isSearching,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventListController = ref.watch(eventController);

    if (eventListController.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (eventListController.hasError) {
      return Center(child: Text('Error loading events.'));
    }

    if (eventListController.events.isEmpty) {
      return Center(child: Text('No events available.'));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: eventListController.events.length,
      itemBuilder: (context, index) {
        final event = eventListController.events[index];
        return EventCard(
          id: event['id'],
          title: event['title'],
          description: event['description'],
          dateTime: event['time'],
          imageUrl: event['image_url'],
          eventType: widget.eventType ?? "Event",
          latLng: LatLng(
            event['location']['latitude'],
            event['location']['longitude'],
          ),
        );
      },
    );
  }
}
