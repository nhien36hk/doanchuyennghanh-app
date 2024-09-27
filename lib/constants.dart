import 'package:app_intern/controller/auth_controller.dart';
import 'package:app_intern/screens/main_screen.dart';
import 'package:app_intern/screens/my_order_screen.dart';
import 'package:app_intern/screens/product_detail_screen.dart';
import 'package:app_intern/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// PAGES
final pages = [
  MainScreen(),
  Center(child: Text('Notification')),
  MyOrderScreen(),
  ProfileScreen(),
];
// COLORS
const buttonColor = Color.fromARGB(255, 249, 106, 66);

// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLER
final authController = AuthController.instance;
