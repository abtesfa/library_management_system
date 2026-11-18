import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_system/core/config/api_config.dart';

void main() {
  test('uses the host bridge for Android emulator requests', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      expect(ApiConfig.baseUrl, 'http://10.0.2.2:8080/api');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  test('uses localhost on desktop platforms', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      expect(ApiConfig.baseUrl, 'http://localhost:8080/api');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
