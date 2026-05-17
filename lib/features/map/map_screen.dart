import 'package:flutter/material.dart';
import 'mobile_map_screen.dart'
    if (dart.library.html) 'web_map_screen.dart' as platform;


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: platform.PlatformMapView(),
    );
  }
}