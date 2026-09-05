import 'package:flutter/material.dart';

/// Consistent solid dark background across every screen.
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  const GradientScaffold({super.key, this.appBar, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: const Color(
        0xFF121016,
      ), // near-black, slight purple tint
      body: body,
    );
  }
}
