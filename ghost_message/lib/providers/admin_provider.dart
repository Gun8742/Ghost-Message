import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ghost_message/models/admin_message_model.dart';
import 'package:ghost_message/services/admin_firestore_service.dart';

class AdminProvider extends ChangeNotifier {
  List<AdminMessageModel> _allMessages = [];
  StreamSubscription? _subscription;
  bool _isInitialized = false; 

  List<AdminMessageModel> get allMessages => _allMessages;

  void initMessages() {
    if (_isInitialized || _subscription != null) return;
    
    _isInitialized = true;

    _subscription = AdminFirestoreService().streamAllContent().listen((messages) {
      _allMessages = messages;
      notifyListeners();
    });
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _allMessages = [];
    _isInitialized = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}