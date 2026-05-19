class Env {
  static const mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static void ensureConfigured(){
    const required = {
      'MAPBOX_ACCESS_TOKEN': mapboxAccessToken,
      'SUPABASE_URL': supabaseUrl,
      'SUPABASE_ANON_KEY': supabaseAnonKey,
    };

    for (final entry in required.entries){
      if (entry.value.isEmpty){
        throw Exception('${entry.key} is not set'
        );
      }
    }
  }
  
  
}