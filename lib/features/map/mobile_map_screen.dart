import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class PlatformMapView extends StatelessWidget {
  const PlatformMapView({super.key});
  @override
  Widget build(BuildContext context) {
    return MapWidget(
      viewport: CameraViewportState(
        center: Point(coordinates: Position(139.767306, 35.681236)),
        zoom: 5.5,
      ),
      styleUri: MapboxStyles.OUTDOORS,
    );
  }
}