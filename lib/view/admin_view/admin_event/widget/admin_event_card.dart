import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:burntech/core/theme/theme_helper.dart';
import 'package:burntech/core/utils_constants/utils_constants.dart';
import 'package:burntech/view/admin_view/admin_event/admin_evets_details.dart';
import 'package:burntech/view/admin_view/admin_event/edit_admin_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../controller/event_controller.dart';
import '../../../../widget/custom_image.dart';
import '../../../user_view/events_page/events_detail_page.dart';

class AdminEventCard extends ConsumerStatefulWidget {
  final String title;
  final String id;
  final String description;
  final String dateTime;
  final String imageUrl;
  final String eventType;
  final LatLng latLng;
  final bool? isDelete;
  final Function()? onTapDelete;

  const AdminEventCard(
      {Key? key,
      required this.id,
      required this.title,
      required this.description,
      required this.dateTime,
      required this.imageUrl,
      required this.eventType,
      required this.latLng,
      required this.onTapDelete,
      this.isDelete})
      : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<AdminEventCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("event id ====  ${widget.id}");
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AdminEvetsDetails(
                  eventId: widget.id,
                )));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade100, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.topRight,
                  fit: BoxFit.fitHeight,
                  image: AssetImage(
                    'assets/images/background_image_p.png',
                  ))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.dateTime,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8.0),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(30)),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) {
                                  return EditAdminEvent(eventId: widget.id);
                                }));
                              },
                              child: Icon(Icons.edit, color: Colors.white,size: 15)),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(30)),
                          child: GestureDetector(
                              onTap: widget.onTapDelete,
                              child: Icon(Icons.delete, color: Colors.white,size: 15,)),
                        ),

                      ],
                    )

                  ],
                ),
              ),
              Flexible(
                child: Center(
                  child: CustomImageView(
                    radius: BorderRadius.circular(10.0),
                    imagePath: widget.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
