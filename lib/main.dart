import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/welcome_view.dart';
import 'package:provider/provider.dart';
import 'viewmodels/app_state.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  
  await Supabase.initialize(
    url: 'https://ewamcesryjrzjyvxupqc.supabase.co', 
    publishableKey: 'sb_publishable_MfYuq4Y1ErOtO1_dTc7ZRA_VOF9aK7O',
  );

 
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifestyle Square Carwash',
      debugShowCheckedModeBanner: false,
      home: const WelcomeView(), 
    );
  }
}