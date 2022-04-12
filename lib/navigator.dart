import 'package:flutter/material.dart';
import 'package:ouraintervention/screens/ProfilePage.dart';

/// This file contains all functions used 
/// for navigating to different pages

/// Navigates to the ProfilePage using the current [context].
void navigateProfilePage(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }