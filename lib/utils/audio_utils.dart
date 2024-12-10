import 'dart:io';
import 'package:intl/intl.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:path_provider/path_provider.dart';

class AudioUtils {
  // 通用音频格式转换方法
  static Future<File?> _convertAudioFile(
    File? inputFile,
    String outputExtension,
    String codec,
    String bitrate, {
    int sampleRate = 16000,
    int channels = 1,
    bool enableVBR = false,
  }) async {
    if (inputFile == null) return null;
    if (!await inputFile.exists()) {
      print('${inputFile.path} file not found');
      return null;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      // 获取当前时间戳并格式化为字符串
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      // 生成带时间戳的输出文件路径
      final String outputPath = '${tempDir.path}/output_$timestamp.$outputExtension';

      final File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete(); // 删除已有的文件
      }

      // 构建 FFmpeg 转换命令
      String command = '-i ${inputFile.path} '
          '-c:a $codec ' // 使用指定的编码器
          '-b:a $bitrate ' // 设置比特率
          '-ar $sampleRate ' // 设置采样率
          '-ac $channels ' // 设置声道数
          '-y '; // 覆盖已存在的文件

      if (enableVBR) {
        command += '-vbr on '; // 启用 VBR 模式
      }

      command += outputPath;

      final FFmpegSession session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();
      final String? error = await session.getFailStackTrace();

      if (error != null) {
        print('FFmpeg error: $error');
      }

      // 如果转换成功，返回转换后的文件
      if (ReturnCode.isSuccess(returnCode)) {
        final File outputAudioFile = File(outputPath);
        if (await outputAudioFile.exists() && await outputAudioFile.length() > 0) {
          print('Conversion successful. Output file: $outputPath');
          return outputAudioFile; // 返回转换后的音频文件
        } else {
          print('Conversion failed: Output file is empty or missing');
        }
      } else {
        print("Conversion failed: ${returnCode?.getValue() ?? 'Unknown error'}");
      }
    } catch (e) {
      print('Error during conversion: $e');
    }

    return null; // 如果出错或转换失败，返回 null
  }

  // 转换音频文件到 Opus 格式
  static Future<File?> convertAudioToOpus(File? file) async {
    return _convertAudioFile(
      file,
      'opus',
      'libopus',
      '16k', // 比特率可以根据需要调整
      enableVBR: true, // 启用 VBR 模式
    );
  }

  // 转换音频文件到 AAC 格式
  static Future<File?> convertAudioToAAC(File? file) async {
    return _convertAudioFile(
      file,
      'aac',
      'aac',
      '16k',
    );
  }

  // 转换音频文件到 MP3 格式
  static Future<File?> convertAudioToMp3(File? file) async {
    return _convertAudioFile(
      file,
      'mp3',
      'libmp3lame',
      '128k', // 可以调整比特率
    );
  }

  // 转换音频文件到 WAV 格式
  static Future<File?> convertAudioToWav(File? file) async {
    return _convertAudioFile(
      file,
      'wav',
      'pcm_s16le',
      '16k',
    );
  }

  // 转换音频文件到 M4A 格式
  static Future<File?> convertAudioToM4a(File? file) async {
    return _convertAudioFile(
      file,
      'm4a',
      'aac',
      '16k',
    );
  }
}
