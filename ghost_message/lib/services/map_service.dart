import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ghost_message/models/post_model.dart';

class MapService {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  BitmapDescriptor? _ghostPostMarkerIcon;
  BitmapDescriptor? _myLocationMarkerIcon;

  Future<bool> checkAndRequestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  

  Future<Position?> getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return _currentPosition;
    } catch (e) {
      return null;
    }
  }

  void startRealtimeLocation({
    required Function(Position position) onChanged,
  }) {
    _positionStreamSubscription?.cancel();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      onChanged(position);
    });
  }

  double calculateDistanceMeter({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

  bool canOpenMarkerIn20Meters({
    required Position? currentPosition,
    required PostModel post,
  }) {
    if (currentPosition == null) return false;

    final double distance = calculateDistanceMeter(
      startLat: currentPosition.latitude,
      startLng: currentPosition.longitude,
      endLat: post.latitude,
      endLng: post.longitude,
    );

    return distance <= 20;
  }

  double getDistanceToPost({
    required Position? currentPosition,
    required PostModel post,
  }) {
    if (currentPosition == null) return 999999;

    return calculateDistanceMeter(
      startLat: currentPosition.latitude,
      startLng: currentPosition.longitude,
      endLat: post.latitude,
      endLng: post.longitude,
    );
  }


  Set<Marker> buildPostMarkers({
    required List<PostModel> posts,
    required void Function(PostModel post) onTapMarker,
  }) {
    Set<Marker> markers = {};

    for (PostModel post in posts) {
      markers.add(
        Marker(
          markerId: MarkerId("post_${post.postId}"),
          position: post.latLng,
          icon: _ghostPostMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          infoWindow: const InfoWindow(
            title: "Ghost Message",
            snippet: "ข้อความ",
          ),
          onTap: () {
            onTapMarker(post);
          },
        ),
      );
    }

    return markers;
  }

  Marker? buildMyLocationMarker(Position? position) {
    if (position == null) return null;

    return Marker(
      markerId: const MarkerId("my_location"),
      position: LatLng(position.latitude, position.longitude),
      icon: _myLocationMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      anchor: const Offset(0.5, 0.9),
      infoWindow: const InfoWindow(
        title: "ตำแหน่งของฉัน",
      ),
      zIndex: 999,
    );
  }

  Circle? buildMy20mCircle(Position? position) {
    if (position == null) return null;

    return Circle(
      circleId: const CircleId("my_20m_range"),
      center: LatLng(position.latitude, position.longitude),
      radius: 20,
      fillColor: const Color(0x2200AEEF),
      strokeColor: const Color(0xAA00AEEF),
      strokeWidth: 2,
    );
  }

  Future<void> initMapIcons() async {
    _ghostPostMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/ghost_pin.jpg'
    );
    _myLocationMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/my_location_pin.png'
    );
  }
  
  Future<void> dispose() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
}