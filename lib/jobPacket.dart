import 'package:flutter/material.dart';
import 'src/managers/packetManager.dart';

class JobPacketPage extends StatefulWidget {
  const JobPacketPage({super.key});

  @override
  State<JobPacketPage> createState() => _JobPacketPageState();
}

class _JobPacketPageState extends State<JobPacketPage> {
  @override
  Widget build(BuildContext context) { 
    return const Scaffold(
      body: PacketManager(),
    );
  }
}