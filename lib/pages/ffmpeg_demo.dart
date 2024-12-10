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
  File? _sourceAudioFile;
  File? _convertedAudioFile;
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _audioPlayer.openPlayer();
    await _loadAudioFileFromAssets();
  }

  // 加载音频文件，默认加载一个mp3文件
  Future<void> _loadAudioFileFromAssets() async {
    setState(() {
      _status = 'Loading audio file...';
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
        throw Exception('Loaded file is empty');
      }

      setState(() {
        _status = 'Audio file loaded successfully';
        _sourceAudioFile = file;
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading file: $e';
      });
    }
  }

  // 转换音频文件，转换为合适的格式
  Future<void> _convertAudio() async {
    final Stopwatch stopwatch = Stopwatch()..start(); // Start timer
    if (_sourceAudioFile == null || !await _sourceAudioFile!.exists()) {
      setState(() {
        _status = 'Source audio file not found';
      });
      return;
    }

    setState(() {
      _status = 'Converting audio...';
    });

    final File? convertedFile = await AudioUtils.convertAudioToMp3(_sourceAudioFile);
    stopwatch.stop(); // Stop timer
    print('Conversion time: ${stopwatch.elapsedMilliseconds} ms'); // Log conversion time

    setState(() {
      _status = 'Audio conversion completed';
      _convertedAudioFile = convertedFile;
    });
  }

  // 播放音频文件
  Future<void> _playAudioFile(File file) async {
    if (!await file.exists()) {
      setState(() {
        _status = 'Audio file not found';
      });
      return;
    }

    try {
      await _audioPlayer.startPlayer(
        fromURI: file.path,
        codec: _getAudioCodec(file), // 使用动态选择的编码格式
        whenFinished: () {
          setState(() {
            _status = 'Playback finished';
          });
        },
      );
      setState(() {
        _status = 'Playing audio...';
      });
    } catch (e) {
      setState(() {
        _status = 'Playback error: $e';
      });
    }
  }

  // 根据文件扩展名动态选择合适的编码格式
  Codec _getAudioCodec(File file) {
    final String extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp3':
        return Codec.mp3;
      case 'wav':
        return Codec.pcm16WAV;
      case 'aac':
        return Codec.aacADTS;
      default:
        return Codec.defaultCodec;
    }
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Converter'),
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
                onPressed: _convertAudio,
                child: const Text('Convert Audio'),
              ),
              const SizedBox(height: 20),
              if (_sourceAudioFile != null)
                ElevatedButton(
                  onPressed: () => _playAudioFile(_sourceAudioFile!),
                  child: const Text('Play Original Audio'),
                ),
              if (_convertedAudioFile != null)
                ElevatedButton(
                  onPressed: () => _playAudioFile(_convertedAudioFile!),
                  child: const Text('Play Converted Audio'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
