import 'dart:convert';

/// Converts an HTTP error response into a short, user-safe diagnostic.
///
/// DeepSeek normally returns JSON, but proxies, captive portals and CDNs often
/// return HTML or a plain-text body. The app must not throw a FormatException
/// while trying to report the original HTTP failure.
String formatApiHttpError({required int statusCode, required String body}) {
  String? message;
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final error = decoded['error'];
      if (error is Map) {
        final value = error['message'];
        if (value is String && value.trim().isNotEmpty) {
          message = value;
        }
      } else if (error is String && error.trim().isNotEmpty) {
        message = error;
      } else {
        final value = decoded['message'];
        if (value is String && value.trim().isNotEmpty) {
          message = value;
        }
      }
    }
  } on FormatException {
    // Non-JSON error body: fall through to the plain-text fallback.
  } catch (_) {
    // Error formatting must never mask the original HTTP status.
  }

  final fallback = body.trim().replaceAll(RegExp(r'\s+'), ' ');
  final text = (message ?? fallback).trim();
  if (text.isEmpty) {
    return 'HTTP $statusCode';
  }
  final clipped = text.length <= 300 ? text : '${text.substring(0, 300)}…';
  return 'HTTP $statusCode: $clipped';
}
