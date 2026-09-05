import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:alpine_plant_map/config/env.dart';
import 'package:alpine_plant_map/features/map/presentation/posts_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlatformMapView extends ConsumerWidget {
  const PlatformMapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー：$e')),
      data: (posts) => FlutterMap(
        options: MapOptions(
        initialCenter: const LatLng(35.681236, 139.767306),
        initialZoom: 5.5,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
          additionalOptions: {
            'accessToken': Env.mapboxAccessToken,
          },
          userAgentPackageName: 'com.example.alpine_plant_map',
        ),
        MarkerLayer(
          markers: posts.map((post) => Marker(
            point: LatLng(post.latitude, post.longitude),
            width: 32,
            height: 32,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 32),
          )).toList(),
        ),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomRight,
          attributions: [
            TextSourceAttribution('Mapbox'),
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
      ),
    );
  }
}