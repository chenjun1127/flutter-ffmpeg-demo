import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ffmpeg-demo');
              },
              child: const Text('Go to FFmpeg demo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/groq-demo');
              },
              child: const Text('Go to Groq demo'),
            ),
          ],
        ),
      ),
    );
  }
}
