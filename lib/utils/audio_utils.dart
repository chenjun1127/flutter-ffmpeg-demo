import 'dart:io';

import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:path_provider/path_provider.dart';

class AudioUtils {
  static Future<File?> convertWavToOpus(File? file) async {
    if (file == null) return null;
    if (!await file.exists()) {
      print('WAV file not found');
      return null;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/output.opus';

      final File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete(); // 如果输出文件已存在，先删除
      }

      // 使用 FFmpeg 转换命令，使用 Opus 编码器
      final String command = '-i ${file.path} -c:a libopus -b:a 64k -vbr on -ar 48000 $outputPath';

      final FFmpegSession session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();
      final String? error = await session.getFailStackTrace();

      if (error != null) {
        print('FFmpeg error: $error');
      }

      // 如果转换成功，返回转换后的文件
      if (ReturnCode.isSuccess(returnCode)) {
        final File opusFile = File(outputPath);
        if (await opusFile.exists() && await opusFile.length() > 0) {
          print('Conversion successful. Opus file: $outputPath');
          return opusFile; // 返回转换后的 Opus 文件
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

  static Future<File?> convertWavToAAC(File? file) async {
    if (file == null) return null;
    if (!await file.exists()) {
      print('WAV file not found');
      return null;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/output.aac';

      final File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete(); // 删除已有的文件
      }

      // AAC 转换和压缩命令
      final String command = '-i ${file.path} '
          '-c:a aac ' // 使用 AAC 编码器
          '-b:a 16k ' // 设置比特率为 16kbps (可以根据需要调整)
          '-ar 16000 ' // 设置采样率
          '-ac 1 ' // 设置为单声道
          '-y ' // 覆盖已存在的文件
          '$outputPath';

      final FFmpegSession session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();
      final String? error = await session.getFailStackTrace();

      if (error != null) {
        print('FFmpeg error: $error');
      }

      if (ReturnCode.isSuccess(returnCode)) {
        final File aacFile = File(outputPath);
        if (await aacFile.exists() && await aacFile.length() > 0) {
          // 计算压缩比
          final double originalSize = await file.length() / 1024; // KB
          final double compressedSize = await aacFile.length() / 1024; // KB
          final double compressionRatio = ((originalSize - compressedSize) / originalSize * 100);

          print('Conversion successful:');
          print('Original size: ${originalSize.toStringAsFixed(2)} KB');
          print('Compressed size: ${compressedSize.toStringAsFixed(2)} KB');
          print('Reduced by: ${compressionRatio.toStringAsFixed(1)}%');

          return aacFile; // 返回转换后的 AAC 文件
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

  // 新增的 MP3 转 AAC 方法
  static Future<File?> convertMp3ToAAC(File? file) async {
    if (file == null) return null;
    if (!await file.exists()) {
      print('MP3 file not found');
      return null;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/output.aac';

      final File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete(); // 删除已有的文件
      }

      // MP3 转换为 AAC 命令
      final String command = '-i ${file.path} '
          '-c:a aac ' // 使用 AAC 编码器
          '-b:a 16k ' // 设置比特率为 16kbps (可以根据需要调整)
          '-ar 16000 ' // 设置采样率为 16000Hz
          '-ac 1 ' // 设置为单声道（如果需要双声道，改为 2）
          '-y ' // 覆盖已存在的文件
          '$outputPath';

      final FFmpegSession session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();
      final String? error = await session.getFailStackTrace();

      if (error != null) {
        print('FFmpeg error: $error');
      }

      if (ReturnCode.isSuccess(returnCode)) {
        final File aacFile = File(outputPath);
        if (await aacFile.exists() && await aacFile.length() > 0) {
          print('Conversion successful. AAC file: $outputPath');
          return aacFile; // 返回转换后的 AAC 文件
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

  static Future<File?> convertMp3ToWav(File? file) async {
    if (file == null) return null;
    if (!await file.exists()) {
      print('MP3 file not found');
      return null;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/output.wav';

      final File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete(); // 删除已有的文件
      }

      // MP3 转 WAV 命令，采样率 16kHz，单声道
      final String command = '-i ${file.path} '
          '-c:a pcm_s16le ' // 使用 PCM 16-bit 编码
          '-ar 16000 ' // 设置采样率为 16kHz
          '-ac 1 ' // 设置为单声道
          '-y ' // 覆盖已存在的文件
          '$outputPath';

      final FFmpegSession session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();
      final String? error = await session.getFailStackTrace();

      if (error != null) {
        print('FFmpeg error: $error');
      }

      if (ReturnCode.isSuccess(returnCode)) {
        final File wavFile = File(outputPath);
        if (await wavFile.exists() && await wavFile.length() > 0) {
          print('Conversion successful. WAV file: $outputPath');
          return wavFile; // 返回转换后的 WAV 文件
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

  static Future<File?> convertMp3ToM4a(File? file) async {
    if (file == null) return null;
    if (!await file.exists()) {
      print('MP3 file not found');
      return null;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/output.m4a';

      final File outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete(); // 删除已有的文件
      }

      // MP3 转 M4A 命令，使用 AAC 编码，采样率 16kHz，单声道，比特率 64kbps
      final String command = '-i ${file.path} '
          '-c:a aac ' // 使用 AAC 编码器
          '-b:a 16k ' // 设置比特率为 16kbps
          '-ar 16000 ' // 设置采样率为 16kHz
          '-ac 1 ' // 设置为单声道
          '-y ' // 覆盖已存在的文件
          '$outputPath';

      final FFmpegSession session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();
      final String? error = await session.getFailStackTrace();

      if (error != null) {
        print('FFmpeg error: $error');
      }

      if (ReturnCode.isSuccess(returnCode)) {
        final File m4aFile = File(outputPath);
        if (await m4aFile.exists() && await m4aFile.length() > 0) {
          print('Conversion successful. M4A file: $outputPath');
          return m4aFile; // 返回转换后的 M4A 文件
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
}
