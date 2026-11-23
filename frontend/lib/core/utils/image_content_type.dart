import 'package:http_parser/http_parser.dart';

MediaType imageContentType(String filename, [String? mimeType]) {
  final mime = (mimeType != null && mimeType.startsWith('image/'))
      ? mimeType
      : switch (filename.toLowerCase().split('.').last) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => 'image/jpeg', // jpg / jpeg
        };
  final parts = mime.split('/');
  return MediaType(parts[0], parts[1]);
}