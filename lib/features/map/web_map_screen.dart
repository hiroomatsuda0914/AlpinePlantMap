import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:alpine_plant_map/config/env.dart';
import 'package:alpine_plant_map/features/map/presentation/posts_provider.dart';
import 'package:alpine_plant_map/features/map/presentation/filter_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alpine_plant_map/features/map/domain/post.dart';

class PlatformMapView extends ConsumerStatefulWidget {
  const PlatformMapView({super.key});
  @override
  ConsumerState<PlatformMapView> createState() => _PlatformMapViewState();
}

class _PlatformMapViewState extends ConsumerState<PlatformMapView> {
  List<Marker> _markers = [];

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsProvider);

    ref.listen<AsyncValue<List<Post>>>(postsProvider, (_, next) {
      next.whenData((posts) {
        if (mounted) {
          setState(() {
            _markers = posts
                .map(
                  (post) => Marker(
                    point: LatLng(post.latitude, post.longitude),
                    width: 32,
                    height: 32,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                )
                .toList();
          });
        }
      });
    });

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(35.681236, 139.767306),
            initialZoom: 5.5,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/tiles/256/{z}/{x}/{y}?access_token={accessToken}',
              additionalOptions: {'accessToken': Env.mapboxAccessToken},
              userAgentPackageName: 'com.example.alpine_plant_map',
            ),
            MarkerLayer(markers: _markers),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomRight,
              attributions: [
                TextSourceAttribution('Mapbox'),
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        if (postsAsync.isLoading)
          const Center(child: CircularProgressIndicator()),
        if (postsAsync.hasError) Center(child: Text('エラー：${postsAsync.error}')),
        const Positioned(top: 0, left: 0, bottom: 0, child: FilterPanel()),
      ],
    );
  }
}
