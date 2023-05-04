import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rhythm_files/utils/rh_files.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<File?> files = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RhFiles.instance.dashboard(
          onPick: (list) {
            files = list;
            setState(() {});
          },
        ),
      ),
    );
  }
}
