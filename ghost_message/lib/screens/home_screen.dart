import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ghost_message/models/post_model.dart';
import 'package:ghost_message/services/map_service.dart';
import 'package:provider/provider.dart';
import 'package:ghost_message/widgets/utility.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapService _mapService = MapService();

  GoogleMapController? _googleMapController;

  bool _isLoading = true;
  bool _isMapReady = false;
  bool _isFollowMyLocation = true;
  bool _isARMode = false;

  Position? _myPosition;

  List<PostModel> _mockPosts = [];
  Set<Marker> _markerSet = {};
  Set<Circle> _circleSet = {};

  static const CameraPosition _defaultCameraPosition = CameraPosition(
    target: LatLng(13.847500, 100.571500),
    zoom: 17,
  );

  @override
  void initState() {
    super.initState();
    _initMapSystem();
  }

  Future<void> _initMapSystem() async {
    final bool isGranted = await _mapService.checkAndRequestLocationPermission();

    if (!isGranted) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ไม่สามารถใช้งานตำแหน่งได้ กรุณาเปิด Location และ Permission"),
        ),
      );
      return;
    }

    final Position? currentPosition = await _mapService.getCurrentLocation();

    await _mapService.initMapIcons();

    _mockPosts = _mapService.getMockPosts();
    _myPosition = currentPosition;

    _rebuildMapData();

    _mapService.startRealtimeLocation(
      onChanged: (Position position) {
        if (!mounted) return;

        setState(() {
          _myPosition = position;
          _rebuildMapData();
        });

        if (_isFollowMyLocation && _isMapReady && _googleMapController != null) {
          _googleMapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          );
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  void _rebuildMapData() {
    final Set<Marker> postMarkers = _mapService.buildMockPostMarkers(
      posts: _mockPosts,
      onTapMarker: _onTapPostMarker,
    );

    final Marker? myMarker = _mapService.buildMyLocationMarker(_myPosition);
    final Circle? myCircle = _mapService.buildMy20mCircle(_myPosition);

    Set<Marker> newMarkers = {...postMarkers};
    Set<Circle> newCircles = {};

    if (myMarker != null) {
      newMarkers.add(myMarker);
    }

    if (myCircle != null) {
      newCircles.add(myCircle);
    }

    _markerSet = newMarkers;
    _circleSet = newCircles;
  }

  void _onTapPostMarker(PostModel post) {
    final bool canOpen = _mapService.canOpenMarkerIn20Meters(
      currentPosition: _myPosition,
      post: post,
    );

    final double distance = _mapService.getDistanceToPost(
      currentPosition: _myPosition,
      post: post,
    );

    if (canOpen) {
      showGhostPostDialog(
        context: context,
        authorName: "Name",
        isAnonymous: true,
        message: post.message,
        onReport: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Report ส่งแล้ว (mock)"),
              duration: Duration(seconds: 1),
            ),
          );
        },
      );
    } else {
      final double remain = distance - 20;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "ไกลเกิน 20 เมตร ❌ (ห่าง ${distance.toStringAsFixed(1)} m)\nต้องเข้าใกล้อีก ${remain.toStringAsFixed(1)} m",
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _goToMyLocation() async {
    if (_myPosition == null || _googleMapController == null) return;

    _isFollowMyLocation = true;

    await _googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_myPosition!.latitude, _myPosition!.longitude),
          zoom: 18,
        ),
      ),
    );
  }

  void _onTapModeButton() {
    setState(() {
      _isARMode = !_isARMode;
    });
  }

  @override
  void dispose() {
    _mapService.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                _isARMode
                  ? Container(
                      color: isDark ? ThemeProvider.bgDark : ThemeProvider.bgLight,
                      child: const Center(
                        child: Text(
                          "AR MODE",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: _defaultCameraPosition,
                      markers: _markerSet,
                      circles: _circleSet,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      onMapCreated: (GoogleMapController controller) async {
                        _googleMapController = controller;
                        _isMapReady = true;

                        if (_myPosition != null) {
                          await controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(_myPosition!.latitude, _myPosition!.longitude),
                                zoom: 18,
                              ),
                            ),
                          );
                        }
                      },
                      onCameraMoveStarted: () {
                        _isFollowMyLocation = false;
                      },
                    ),

                Positioned(
                  top: 55,
                  right: 12,
                  child: SafeArea(
                    child: Material(
                      color: isDark ? ThemeProvider.buttonDark : ThemeProvider.buttonLight,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _onTapModeButton,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.layers_outlined, size: 18, color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight),
                              SizedBox(width: 6),
                              Text(
                                "Mode",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (!_isARMode)
                  Positioned(
                    right: 12,
                    bottom: 90,
                    child: FloatingActionButton(
                      heroTag: "my_location_btn",
                      mini: true,
                      onPressed: _goToMyLocation,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
              ],
            ),
    );
  }
}

// Widget _buildAR() {
//   return Stack(
//     // children: [
//     //   ArCoreView(
//     //     onArCoreViewCreated: _arService.onArCoreViewCreated,
//     //     enableTapRecognizer: true,
//     //     // onPlaneTap: _arService.onPlaneTap,
//     //   ),
//     //   Positioned(
//     //     top: 12,
//     //     left: 12,
//     //     child: ElevatedButton.icon(
//     //       onPressed: _exitAR,
//     //       icon: const Icon(Icons.arrow_back),
//     //       label: const Text('กลับ'),
//     //     ),
//     //   ),
//     // ],
//   );
// }