import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/tomori_app.dart';
import 'data/local/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // The app can still open without AI configuration.
  }
  try {
    await AppDatabase.instance.open();
  } on UnsupportedError {
    // Web preview uses the same UI with mock data; SQLite is for mobile builds.
  }
  runApp(const TomoriApp());
}
