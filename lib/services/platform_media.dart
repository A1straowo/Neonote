import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformMediaService {
  PlatformMediaService._();

  static const MethodChannel _channel = MethodChannel('neonote/media');

  static bool get isMobile => _isMobile;

  static bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static Future<String?> pickImageFromGallery() async {
    if (!_isMobile) return null;
    try {
      final path = await _channel.invokeMethod<String>('pickImage');
      return (path == null || path.isEmpty) ? null : path;
    } on MissingPluginException {
      return null;
    } catch (error) {
      debugPrint('pickImageFromGallery failed: $error');
      return null;
    }
  }

  static Future<String?> takePhoto() async {
    if (!_isMobile) return null;
    try {
      final path = await _channel.invokeMethod<String>('takePhoto');
      return (path == null || path.isEmpty) ? null : path;
    } on MissingPluginException {
      return null;
    } catch (error) {
      debugPrint('takePhoto failed: $error');
      return null;
    }
  }

  static Future<bool> startRecording() async {
    if (!_isMobile) return false;
    try {
      return await _channel.invokeMethod<bool>('startRecording') ?? false;
    } on MissingPluginException {
      return false;
    } catch (error) {
      debugPrint('startRecording failed: $error');
      return false;
    }
  }

  static Future<String?> stopRecording() async {
    if (!_isMobile) return null;
    try {
      return await _channel.invokeMethod<String>('stopRecording');
    } on MissingPluginException {
      return null;
    } catch (error) {
      debugPrint('stopRecording failed: $error');
      return null;
    }
  }

  static Future<bool> playAudio(String path) async {
    if (!_isMobile) return false;
    try {
      return await _channel.invokeMethod<bool>('playAudio', {'path': path}) ??
          false;
    } on MissingPluginException {
      return false;
    } catch (error) {
      debugPrint('playAudio failed: $error');
      return false;
    }
  }

  static Future<void> stopAudio() async {
    if (!_isMobile) return;
    try {
      await _channel.invokeMethod<void>('stopAudio');
    } catch (_) {}
  }
}
