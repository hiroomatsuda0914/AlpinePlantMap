import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alpine_plant_map/features/map/presentation/post_creation_notifier.dart';
import 'package:flutter/material.dart';
import 'package:alpine_plant_map/features/map/presentation/post_creation_sheet.dart';
import 'mobile_map_screen.dart'
    if (dart.library.html) 'web_map_screen.dart' as platform;


class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const platform.PlatformMapView(),
      floatingActionButton: Consumer(
        builder: (context, ref, _) => FloatingActionButton(
        onPressed: () {
          ref.read(postCreationProvider.notifier).reset();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const PostCreationSheet(),
          );
        },
        child: Icon(Icons.add),
      ),),
    );
  }
}