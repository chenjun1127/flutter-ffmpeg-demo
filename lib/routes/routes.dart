import 'package:flutter/material.dart';
import 'package:flutter_ffmpg/pages/ffmpeg_demo.dart';
import 'package:flutter_ffmpg/pages/groq_demo.dart';
import 'package:flutter_ffmpg/pages/home_page.dart';

// 路由配置
class AppRoutes {
  static const String home = '/home';
  static const String ffmpeg = '/ffmpeg-demo';
  static const String groq = '/groq-demo';

  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      home: (BuildContext context) => const HomePage(),
      ffmpeg: (BuildContext context) => const FFmpegDemo(),
      groq: (BuildContext context) => const ChatScreen(),
    };
  }
}
