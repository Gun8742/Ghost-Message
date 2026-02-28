import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/services/post_service.dart';
import 'package:ghost_message/widgets/post_sheet.dart';
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

  final PostService _postService = PostService();
  StreamSubscription<List<PostModel>>? _postStreamSubscription;
  List<PostModel> _realPosts = [];
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
    final bool isGranted =
        await _mapService.checkAndRequestLocationPermission();

    if (!isGranted) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final l = Provider.of<L>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.locationPermissionDenied)),
      );
      return;
    }

    final Position? currentPosition = await _mapService.getCurrentLocation();

    await _mapService.initMapIcons();

    _myPosition = currentPosition;

    _postStreamSubscription = _postService.streamNearByPosts().listen((posts) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        _realPosts = posts;
        _rebuildMapData();
      });
    });

    _mapService.startRealtimeLocation(
      onChanged: (Position position) {
        if (!mounted) return;

        setState(() {
          _myPosition = position;
          _rebuildMapData();
        });

        if (_isFollowMyLocation &&
            _isMapReady &&
            _googleMapController != null) {
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
    final Set<Marker> postMarkers = _mapService.buildPostMarkers(
      posts: _realPosts,
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      final l = Provider.of<L>(context, listen: false);
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.pleaseLoginFirst)),
        );
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return PostSheet(
            post: post,
            currentUser: currentUser,
          );
        }
      );
    } else {
      final double remain = distance - 20;

      final l = Provider.of<L>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.distanceTooFar(distance.toStringAsFixed(1), remain.toStringAsFixed(1))),
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

  void _showCreatePostSheet() {
    final l = Provider.of<L>(context, listen: false);
    if (_myPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.findingLocation)),
      );
      return;
    }
    final TextEditingController messageController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            final bool isDark = themeProvider.isDarkMode;
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.createPostTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: messageController,
                    maxLength: 200,
                    maxLines: 4,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: l.createPostHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed:
                          isSubmitting
                              ? null
                              : () async {
                                final text = messageController.text.trim();
                                if (text.isEmpty) return;
                                setSheetState(() => isSubmitting = true);
                                try {
                                  final userProvider =
                                      Provider.of<UserProvider>(
                                        context,
                                        listen: false,
                                      );
                                  final currentUser = userProvider.currentUser;
                                  if (currentUser == null)
                                    throw Exception("Log in First man");

                                  await PostService().createPost(
                                    authorId: currentUser.uid,
                                    message: text,
                                    latitude: _myPosition!.latitude,
                                    longitude: _myPosition!.longitude,
                                  );
                                  if (mounted) {
                                    Navigator.pop(context); // ปิดหน้าต่าง
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l.createPostSuccess),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setSheetState(() => isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l.errorOccurred(e.toString())),
                                    ),
                                  );
                                }
                              },
                      child:
                          isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                l.createPostButton,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onTapModeButton() {
    setState(() {
      _isARMode = !_isARMode;
    });
  }

  @override
  void dispose() {
    _postStreamSubscription?.cancel();
    _mapService.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<L>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  _isARMode
                      ? Container(
                        color:
                            isDark
                                ? ThemeProvider.bgDark
                                : ThemeProvider.bgLight,
                        child: const Center(
                          child: Text(
                            "AR MODE",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                                  target: LatLng(
                                    _myPosition!.latitude,
                                    _myPosition!.longitude,
                                  ),
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
                        color:
                            isDark
                                ? ThemeProvider.buttonDark
                                : ThemeProvider.buttonLight,
                        borderRadius: BorderRadius.circular(20),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _onTapModeButton,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.layers_outlined,
                                  size: 18,
                                  color:
                                      isDark
                                          ? ThemeProvider.textDark
                                          : ThemeProvider.textLight,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  l.mapMode,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark
                                            ? ThemeProvider.textDark
                                            : ThemeProvider.textLight,
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
                      bottom: (MediaQuery.of(context).size.height / 8) + 90,
                      right: MediaQuery.of(context).size.width / 15 + 10,
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: FloatingActionButton(
                          heroTag: "my_location_btn",
                          backgroundColor: isDark ? ThemeProvider.buttonDark : Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          onPressed: _goToMyLocation,
                          child: Icon(
                            Icons.my_location,
                            size: 24,
                            color: isDark ? ThemeProvider.textDark : Colors.blue,
                          ),
                        ),
                      ),
                    ),

                  if (!_isARMode)
                    Positioned(
                      bottom: MediaQuery.of(context).size.height / 8,
                      right: MediaQuery.of(context).size.width / 15,
                      child: SizedBox(
                        height: 70,
                        width: 70,
                        child: FloatingActionButton(
                          backgroundColor: Colors.black,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                          onPressed: _showCreatePostSheet,
                          child: const Icon(
                            Icons.add,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
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
