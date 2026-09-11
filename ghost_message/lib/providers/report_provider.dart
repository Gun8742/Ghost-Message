import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ghost_message/models/report_model.dart';
import 'package:ghost_message/services/report_firestore_service.dart';

class ReportProvider with ChangeNotifier {
  List<ReportModel> _allReports = [];
  StreamSubscription? _subscription;
  bool _isInitialized = false;

  List<ReportModel> get allReports => _allReports;

  void initReports() {
    if (_isInitialized || _subscription != null) return;
    _isInitialized = true;

    _subscription = ReportFirestoreService().getReportList().listen((reports) {
      _allReports = reports;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}