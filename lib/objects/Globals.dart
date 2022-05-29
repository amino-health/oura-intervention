import 'package:flutter/material.dart';

/// Color scheme:
Color mainColor = const Color(0xFF193352);
Color secondaryColor = const Color(0xFF254b79);
Color dark = const Color(0xFF1e1d1d);
Color grey = const Color(0xFFe7e7e6);

/// Shared coach and user data:
bool isAdmin = false;
String username = "";

/// User data:
/// This is stored locally to reduce the number of reads from the database
List<Map<String, dynamic>> messages = [];
List<Map<String, String>> actions = [];
List<Map<String, dynamic>> sleepData = [];

String startDate = "";
String endDate = "";

String latestUpdate = "No data";

/// Coach data:
String? coachedId;
List<Map<String, String>> users = [];

void resetGlobals() {
  actions = [];
  messages = [];
  sleepData = [];
}

void resetAllGlobals() {
  resetGlobals();
  isAdmin = false;
  username = "";
  coachedId = null;
  users = [];
}
