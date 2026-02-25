import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostModel {
  final String id;
  final String message;
  final double latitude;
  final double longitude;

  PostModel({
    required this.id,
    required this.message,
    required this.latitude,
    required this.longitude,
  });

  LatLng get latLng => LatLng(latitude, longitude);
}