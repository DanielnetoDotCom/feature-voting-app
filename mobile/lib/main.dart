import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FeatureVotingApp());
}

class FeatureVotingApp extends StatelessWidget {
  const FeatureVotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feature Voting App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
