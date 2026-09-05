import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/machine_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init(); // load or create the persistent device ID first
  runApp(const SmartLaundryApp());
}

class SmartLaundryApp extends StatelessWidget {
  const SmartLaundryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MachineProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Laundry',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
