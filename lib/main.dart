import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/managers/save_manager.dart';
import 'ui/screens/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for consistent gameplay
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final saveManager = SaveManager();
  await saveManager.load();

  runApp(BombingWarApp(saveManager: saveManager));
}

class BombingWarApp extends StatelessWidget {
  const BombingWarApp({super.key, required this.saveManager});

  final SaveManager saveManager;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bombing War',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB800),
          secondary: Color(0xFFFF4444),
        ),
      ),
      home: MainMenuScreen(saveManager: saveManager),
    );
  }
}
