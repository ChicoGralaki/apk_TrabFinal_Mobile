import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'pages/auth/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } on UnsupportedError catch (error) {
    debugPrint('$error');
  } on FirebaseException catch (error) {
    debugPrint('Firebase initialization failed: ${error.code}');
  }
  runApp(HogwartsExplorerApp(firebaseReady: firebaseReady));
}

class HogwartsExplorerApp extends StatelessWidget {
  const HogwartsExplorerApp({super.key, required this.firebaseReady});
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hogwarts Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AuthGate(firebaseReady: firebaseReady),
    );
  }
}
