import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:ghost_message/services/notification_service.dart';
import 'package:provider/provider.dart';

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

  Position? _myPosition;

  final PostService _postService = PostService();
  StreamSubscription<List<PostModel>>? _postStreamSubscription;
  List<PostModel> _realPosts = [];
  Set<Marker> _markerSet = {};
  Set<Circle> _circleSet = {};
  final Set<String> _seenNearbyPostIds = {};
  bool _hasLoadedInitialNearbyPosts = false;
  Position? _lastNotificationBasePosition;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.locationPermissionDenied)));
      return;
    }

    final Position? currentPosition = await _mapService.getCurrentLocation();

    await _mapService.initMapIcons();

    _myPosition = currentPosition;

    _postStreamSubscription = _postService.streamNearByPosts().listen((posts) async {
      if (!context.mounted) {
        return;
      }

      await _handleNearbyPostNotifications(posts);

      if (!mounted) return;

      setState(() {
        _realPosts = posts;
        _rebuildMapData();
      });
    });

    _mapService.startRealtimeLocation(
      onChanged: (Position position) {
        if (!mounted) return;

         _resetNearbyNotificationStateIfNeeded(position);

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

  Future<void> _handleNearbyPostNotifications(List<PostModel> posts) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return;
    }

    if (!currentUser.isNotificationEnabled ||
        !currentUser.isNearbyChatEnabled ||
        !currentUser.isLocationEnabled) {
      return;
    }

    if (_myPosition == null) {
      return;
    }

    final List<PostModel> nearbyPosts = posts.where((post) {
      if (post.authorId == currentUser.uid) {
        return false;
      }

      final double distance = Geolocator.distanceBetween(
        _myPosition!.latitude,
        _myPosition!.longitude,
        post.latitude,
        post.longitude,
      );

      return distance <= 20.0;
    }).toList();

    if (!_hasLoadedInitialNearbyPosts) {
      _seenNearbyPostIds.addAll(nearbyPosts.map((post) => post.postId));
      _hasLoadedInitialNearbyPosts = true;
      return;
    }
    
    final List<PostModel> newNearbyPosts = nearbyPosts.where((post) {
        return !_seenNearbyPostIds.contains(post.postId);
    }).toList();

    for (final post in newNearbyPosts) {
      final String authorName = userProvider.getUsernameById(post.authorId);

      await NotificationService().createUserNotification(
        recipientUid: currentUser.uid,
        actorUid: post.authorId,
        actorName: authorName,
        type: "nearby_post",
        title: "New Nearby Post",
        body: "$authorName posted a new ghost message nearby",
        postId: post.postId,
      );

      NotificationService().showInAppSnackBar(
        title: "New Nearby Post",
        body: "$authorName posted a new ghost message nearby",
      );

      _seenNearbyPostIds.add(post.postId);
    }
  }

  void _openSinglePost(PostModel post) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    final l = Provider.of<L>(context, listen: false);
    if (currentUser == null) return;
    final postDoc = await FirebaseFirestore.instance.collection('posts').doc(post.postId).get();

    if (!postDoc.exists) {
      if (currentUser.likedPosts.contains(post.postId)) {
        await userProvider.removeInvalidLikedItem(post.postId, true);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.postAlreadyDeleted)),
        );
      }
      return;
    }
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostSheet(post: post, currentUser: currentUser),
    );
  }

  void _showPostListAtLocation(List<PostModel> posts) {
    final l = Provider.of<L>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "${l.adminSubMessage} (${posts.length})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: posts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: themeProvider.isDarkMode ? Colors.black26 : Colors.grey[200],
                      backgroundImage: (userProvider.getPhotoPath(post.authorId) != null && 
                                        userProvider.getPhotoPath(post.authorId)!.isNotEmpty)
                          ? NetworkImage(userProvider.getPhotoPath(post.authorId)!)
                          : null,
                      child: (userProvider.getPhotoPath(post.authorId) == null || 
                              userProvider.getPhotoPath(post.authorId)!.isEmpty)
                          ? Icon(Icons.person, size: 18, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54)
                          : null,
                  ),
                    title: Text(
                      post.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                    ),
                    subtitle: Text(
                      "@${userProvider.getUsernameById(post.authorId)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.pop(context);
                      _openSinglePost(post);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
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
      final List<PostModel> postsAtSameLocation = _realPosts.where((p) {
      double distance = Geolocator.distanceBetween(
        post.latitude, post.longitude, 
        p.latitude, p.longitude
      );
      return distance < 1.0;
      }).toList();

      if (postsAtSameLocation.length > 1) {
        _showPostListAtLocation(postsAtSameLocation);
      } 
      else {
        _openSinglePost(post);
      }
    } 
    else {
      final double remain = distance - 20;

      final l = Provider.of<L>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.distanceTooFar(
              distance.toStringAsFixed(1),
              remain.toStringAsFixed(1),
            ),
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

  void _showCreatePostSheet() {
    final l = Provider.of<L>(context, listen: false);
    if (_myPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.findingLocation)));
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
                                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                                  final currentUser = userProvider.currentUser;
                                  final l = Provider.of<L>(context, listen: false);
                                  if (currentUser == null)
                                    throw Exception(l.loginFirstToDropMessage);

                                  await PostService().createPost(
                                    authorId: currentUser.uid,
                                    message: text,
                                    latitude: _myPosition!.latitude,
                                    longitude: _myPosition!.longitude,
                                  );
                                  Provider.of<UserProvider>(context, listen: false).gainExp(5);
                                  if (mounted) {
                                    Navigator.pop(context);
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
                                      content: Text(
                                        l.errorOccurred(e.toString()),
                                      ),
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

  void _manageLocationSync() {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null || !currentUser.isLocationEnabled) {
      _mapService.dispose();
      
      if (mounted && _myPosition != null) {
        setState(() {
          _myPosition = null;
          _rebuildMapData();
        });
      }
    } else {
      if (_myPosition == null) {
        _initMapSystem(); 
      }
    }
  }

  @override
  void dispose() {
    _postStreamSubscription?.cancel();
    _mapService.dispose();
    _googleMapController?.dispose();
    super.dispose();
  }

  void _resetNearbyNotificationStateIfNeeded(Position newPosition) {
    if (_lastNotificationBasePosition == null) {
      _lastNotificationBasePosition = newPosition;
      return;
    }

    final double movedDistance = Geolocator.distanceBetween(
      _lastNotificationBasePosition!.latitude,
      _lastNotificationBasePosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (movedDistance > 50) {
      _seenNearbyPostIds.clear();
      _hasLoadedInitialNearbyPosts = false;
      _lastNotificationBasePosition = newPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    _manageLocationSync();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
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
                    bottom: (MediaQuery.of(context).size.height / 8) + 90,
                    right: MediaQuery.of(context).size.width / 15 + 10,
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: FloatingActionButton(
                        heroTag: "my_location_btn",
                        backgroundColor:
                            isDark ? ThemeProvider.buttonDark : Colors.white,
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
