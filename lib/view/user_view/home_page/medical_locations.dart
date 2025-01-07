import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controller/home_controller.dart';


class MedicalLocation extends ConsumerStatefulWidget {
  @override
  _MedicalLocationState createState() => _MedicalLocationState();
}

class _MedicalLocationState extends ConsumerState<MedicalLocation> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(40.7864, -119.2066);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback)async{
      final homeData = ref.watch(homeProvider);
      homeData.loadMarkers(context);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
   final homeData = ref.watch(homeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospitals at Burning Man'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
        markers: homeData.markerPoints,
      ),
    );
  }
}
