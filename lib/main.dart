import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'GuestDashboard.dart';
void main() async {
 WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBbSQOdsCh7ImLhewcIhHUTcj9-1xbShQk",
          authDomain: "lspumart.firebaseapp.com",
          databaseURL:
              "https://lspumart-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "lspumart",
          storageBucket: "lspumart.firebasestorage.app",
          messagingSenderId: "533992551897",
          appId: "1:533992551897:web:d04a482ad131a0700815c8"),
    );
  } else {
    await Firebase.initializeApp();
  }

  await Supabase.initialize(
    url: 'https://haoiqctsijynxwfoaspm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhb2lxY3RzaWp5bnh3Zm9hc3BtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxNzU3MDMsImV4cCI6MjA1OTc1MTcwM30.7kilmu9kxrABgg4ZMz9GIHm5Jv4LHLAIYR1_8q1eDEI',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GuestDashboard(),
    );
  }
}