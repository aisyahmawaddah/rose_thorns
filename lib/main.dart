import 'package:flutter/material.dart';
import 'package:koopon/app.dart';
import 'package:koopon/data/services/firebase_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(KooponApp());
}