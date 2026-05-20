import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alpine_plant_map/config/env.dart';
import 'package:alpine_plant_map/config/mapbox_bootstrap_mobile.dart'
    if (dart.library.html) 'package:alpine_plant_map/config/mapbox_bootstrap_stub.dart';
import 'package:alpine_plant_map/features/map/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.ensureConfigured();
  configureMapbox(Env.mapboxAccessToken);
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  runApp(const AlpinePlantMap());
}

class AlpinePlantMap extends StatelessWidget {
  const AlpinePlantMap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpine Plant Map',
      home: const MapScreen(),
    );
  }
}