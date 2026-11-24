import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/pages/dashboard_page.dart';

void main() => runApp(const ProviderScope(child: IotLiveMonitorApp()));

class IotLiveMonitorApp extends StatelessWidget {
  const IotLiveMonitorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'IoT Live Monitor',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    darkTheme: ThemeData(
      colorSchemeSeed: Colors.teal,
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    themeMode: ThemeMode.dark,
    home: const DashboardPage(),
  );
}
