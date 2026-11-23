import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../../core/utils/image_content_type.dart';

import '../../../../core/config/api_config.dart';

class SettingsRemoteDataSource {
  static const String baseUrl = '${ApiConfig.baseUrl}/settings';

  // GET: Load settings from Spring Boot
  Future<Map<String, dynamic>> getSettings() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load settings: ${response.statusCode} ${response.body}',
    );
  }

  
Future<void> uploadLogo(Uint8List bytes, String filename) async {
  final extension = filename.split('.').last.toLowerCase();

  final MediaType contentType;

  switch (extension) {
    case 'jpg':
    case 'jpeg':
      contentType = MediaType('image', 'jpeg');
      break;
    case 'png':
      contentType = MediaType('image', 'png');
      break;
    case 'webp':
      contentType = MediaType('image', 'webp');
      break;
    default:
      throw ArgumentError('Only JPG, PNG, and WEBP images are allowed.');
  }

  final request = http.MultipartRequest(
    'PUT',
    Uri.parse('$baseUrl/logo'),
  );

      request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: imageContentType(filename),
    ));

  final streamed = await request.send();

  if (streamed.statusCode != 204) {
    final body = await streamed.stream.bytesToString();
    throw Exception(
      'Failed to upload logo: ${streamed.statusCode} $body',
    );
  }
}


  // PUT: Update settings in Spring Boot
  Future<Map<String, dynamic>> updateSettings({
    required String libraryName,
    required int maxBooksPerStudent,
    required int maxBorrowingDays,
    required int renewalLimit,
    required double finePerDay,
    required int reservationHoldMinutes,
    required String schoolEmail,
    required String schoolLocation,
  }) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'libraryName': libraryName,
        'maxBooksPerStudent': maxBooksPerStudent,
        'maxBorrowingDays': maxBorrowingDays,
        'renewalLimit': renewalLimit,
        'finePerDay': finePerDay,
        'reservationHoldMinutes': reservationHoldMinutes,
        'schoolEmail': schoolEmail,
        'schoolLocation': schoolLocation,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to save settings: ${response.statusCode} ${response.body}',
    );
  }
}
