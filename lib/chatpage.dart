import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesan"),
      ),
      body: const Center(
        child: Text("Fitur chat akan tersedia di sini."),
      ),
    );
  }
}
