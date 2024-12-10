import 'package:flutter/material.dart';
import 'package:gestion_vetement/splashScreen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initPathProvider();

  runApp(const MyApp());
}

Future<void> _initPathProvider() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    print('Directory path: ${directory.path}');
  } catch (e) {
    print('Error getting directory: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MATERIAL Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
