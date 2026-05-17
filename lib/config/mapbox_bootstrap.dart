import 'mapbox_bootstrap_mobile.dart'
    if (dart.library.html) 'mapbox_bootstrap_stub.dart' as mapbox_impl;

void configureMapbox(String token) => mapbox_impl.configureMapbox(token);