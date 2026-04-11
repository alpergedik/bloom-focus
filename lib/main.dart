import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = BloomAppState();
  await appState.loadFromStorage();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const BloomFocusApp(),
    ),
  );
}