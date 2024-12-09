import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpg/utils/audio_utils.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class FFmpegDemo extends StatefulWidget {
  const FFmpegDemo({super.key});

  @override
  _FFmpegDemoState createState() => _FFmpegDemoState();
}

class _FFmpegDemoState extends State<FFmpegDemo> {
  String _status = 'Idle';
  File? _wavFile;
  File? _aacFile;
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _player.openPlayer();
    await loadFileFromAssets();
  }

  Future<void> loadFileFromAssets() async {
    setState(() {
      _status = 'Loading WAV file...';
    });

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempFilePath = '${tempDir.path}/input.mp3';

      final File file = File(tempFilePath);
      if (await file.exists()) {
        await file.delete();
      }

      final ByteData byteData = await rootBundle.load('assets/resources/1.mp3');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (await file.length() == 0) {
        throw Exception('File is empty');
      }

      setState(() {
        _status = 'File loaded successfully';
        _wavFile = file;
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading : $e';
      });
    }
  }

  Future<void> convertWavToAAC() async {
    final Stopwatch stopwatch = Stopwatch()..start(); // 开始计时
    if (_wavFile == null || !await _wavFile!.exists()) {
      setState(() {
        _status = 'File not found';
      });
      return;
    }

    setState(() {
      _status = 'Converting and compressing...';
    });

    final File? file = await AudioUtils.convertWavToOpus(_wavFile);
    stopwatch.stop(); // 停止计时
    print('Conversion time: ${stopwatch.elapsedMilliseconds} ms'); // 输出耗时
    setState(() {
      _status = 'Conversion and compression completed';
      _aacFile = file;
    });
  }

  Future<void> playAudioFile(File file) async {
    if (!await file.exists()) {
      setState(() {
        _status = 'Audio file not found';
      });
      return;
    }

    try {
      await _player.startPlayer(
        fromURI: file.path,
        codec: file == _wavFile ? Codec.pcm16WAV : Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _status = 'Playback finished';
          });
        },
      );
      setState(() {
        _status = 'Playing...';
      });
    } catch (e) {
      setState(() {
        _status = 'Playback error: $e';
      });
    }
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WAV to AAC Converter'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Status: $_status',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: convertWavToAAC,
                child: const Text('Convert & Compress to AAC'),
              ),
              const SizedBox(height: 20),
              if (_wavFile != null)
                ElevatedButton(
                  onPressed: () => playAudioFile(_wavFile!),
                  child: const Text('Play Original WAV'),
                ),
              if (_aacFile != null)
                ElevatedButton(
                  onPressed: () => playAudioFile(_aacFile!),
                  child: const Text('Play Compressed AAC'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
