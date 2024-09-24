import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:edge_tts/edge_tts.dart' as edge_tts;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AudioPlayer player;


  @override
  void initState(){
    super.initState();
    player = AudioPlayer();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _onPressed() async {
    BytesBuilder builder = BytesBuilder();
    var communicate = edge_tts.Communicate(text:"hey hey hey");
    await for (var message in communicate.stream()) {
      if (message['type'] == 'audio') {
        builder.add(message['data']);
      }
    }
    player.play(BytesSource(builder.toBytes()));

    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloze Call'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/learn');
              },
              icon: const Icon(Icons.school),
              label: const Text("Learn"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onPressed,
              icon: const Icon(Icons.language),
              label: const Text("Language"),
            ),
          ],
        ),
      ),
    );
  }
}