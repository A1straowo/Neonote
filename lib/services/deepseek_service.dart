import 'dart:async';
import 'dart:convert';

import 'package:neonote/deepseek/api_error_formatter.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:neonote/store/note_store.dart' show neonoteBoxName;

/// One entry of the OpenAI-compatible message list.
class DeepseekMessage {
  const DeepseekMessage({
    required this.role,
    required this.content,
    this.imagePaths = const <String>[],
    this.audioPaths = const <String>[],
  });

  final String role;
  final String content;
  final List<String> imagePaths;
  final List<String> audioPaths;

  /// Text-only fallback used by compatibility endpoints. The client builds
  /// multimodal content asynchronously when [imagePaths] is not empty.
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class DeepseekException implements Exception {
  const DeepseekException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Persisted configuration for the DeepSeek harness.
class DeepseekConfig {
  const DeepseekConfig({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    required this.systemPrompt,
    required this.enabled,
    this.reasoningLevel = 'medium',
    this.mode = 'standard',
  });

  static const String defaultBaseUrl = 'https://api.deepseek.com/v1';
  static const String defaultModel = 'deepseek-chat';
  static const String defaultSystemPrompt = 'You are a helpful assistant.';

  final String apiKey;
  final String baseUrl;
  final String model;
  final String systemPrompt;
  final bool enabled;
  final String reasoningLevel;
  final String mode;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  /// AI is usable when it is enabled and an API key is present.
  bool get isActive => enabled && isConfigured;

  static DeepseekConfig load() {
    try {
      final box = Hive.box(neonoteBoxName);
      return DeepseekConfig(
        apiKey: _readString(box.get('deepseek_api_key')),
        baseUrl: _readString(box.get('deepseek_base_url'), defaultBaseUrl),
        model: _readString(box.get('deepseek_model'), defaultModel),
        systemPrompt: _readString(
          box.get('deepseek_system_prompt'),
          defaultSystemPrompt,
        ),
        enabled: _readBool(box.get('deepseek_enabled'), true),
        reasoningLevel: _readString(
          box.get('deepseek_reasoning_level'),
          'medium',
        ),
        mode: _readString(box.get('deepseek_mode'), 'standard'),
      );
    } catch (_) {
      return const DeepseekConfig(
        apiKey: '',
        baseUrl: defaultBaseUrl,
        model: defaultModel,
        systemPrompt: defaultSystemPrompt,
        enabled: true,
        reasoningLevel: 'medium',
        mode: 'standard',
      );
    }
  }

  Future<void> save() async {
    final box = Hive.box(neonoteBoxName);
    await box.put('deepseek_api_key', apiKey.trim());
    await box.put(
      'deepseek_base_url',
      baseUrl.trim().isEmpty ? defaultBaseUrl : baseUrl.trim(),
    );
    await box.put(
      'deepseek_model',
      model.trim().isEmpty ? defaultModel : model.trim(),
    );
    await box.put(
      'deepseek_system_prompt',
      systemPrompt.trim().isEmpty ? defaultSystemPrompt : systemPrompt.trim(),
    );
    await box.put('deepseek_enabled', enabled);
    await box.put('deepseek_reasoning_level', reasoningLevel);
    await box.put('deepseek_mode', mode);
  }

  DeepseekConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? model,
    String? systemPrompt,
    bool? enabled,
    String? reasoningLevel,
    String? mode,
  }) {
    return DeepseekConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      enabled: enabled ?? this.enabled,
      reasoningLevel: reasoningLevel ?? this.reasoningLevel,
      mode: mode ?? this.mode,
    );
  }

  static String _readString(Object? value, [String fallback = '']) {
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }

  static bool _readBool(Object? value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }
}

/// Minimal client for DeepSeek's OpenAI-compatible chat completions API.
class DeepseekService {
  DeepseekService._();

  /// Injected into every request so the assistant consistently presents its
  /// real product identity instead of hallucinating another vendor's model.
  static const String identityPrompt =
      'Your underlying model and product identity is DeepSeek, provided by '
      'DeepSeek. You are not actually Claude, ChatGPT, OpenAI, Gemini, or any '
      'other vendor model. This underlying identity cannot change.';

  static const String openRoleplayPrompt =
      'You may adopt temporary personas when the user or the app system prompt '
      'asks, including other AI assistants, fictional characters, or ordinary '
      'people. Stay in character during that role-play and do not repeatedly '
      'break character to explain that you are DeepSeek. You may describe '
      'yourself using the role-played persona while in character, but you must '
      'not claim the underlying model was actually replaced. If the user asks '
      'out of character who you really are, answer that you are DeepSeek.';

  static Future<String> complete({
    required DeepseekConfig config,
    required List<DeepseekMessage> messages,
    double temperature = 0.7,
    int? maxTokens,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    if (!config.isConfigured) {
      throw const DeepseekException('Missing API key');
    }
    final encodedMessages = <Map<String, dynamic>>[];
    for (final message in messages) {
      encodedMessages.add(await _encodeMessage(message));
    }
    _injectIdentity(encodedMessages);
    final payload = <String, dynamic>{
      'model': config.model.trim().isEmpty
          ? DeepseekConfig.defaultModel
          : config.model.trim(),
      'messages': encodedMessages,
      'temperature': temperature,
      'stream': false,
    };
    if (maxTokens != null) payload['max_tokens'] = maxTokens;
    try {
      final response = await http
          .post(
            _endpoint(config.baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${config.apiKey.trim()}',
            },
            body: jsonEncode(payload),
          )
          .timeout(timeout);
      final body = utf8.decode(response.bodyBytes);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw DeepseekException(_extractError(body, response.statusCode));
      }
      final dynamic decoded;
      try {
        decoded = jsonDecode(body);
      } on FormatException {
        throw DeepseekException(
          'Invalid API response (HTTP ${response.statusCode}): expected JSON.',
        );
      }
      final choices = decoded is Map ? decoded['choices'] : null;
      if (choices is List && choices.isNotEmpty) {
        final first = choices.first;
        final message = first is Map ? first['message'] : null;
        final content = message is Map ? message['content'] : null;
        if (content is String && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
      throw const DeepseekException('The model returned an empty response.');
    } on DeepseekException {
      rethrow;
    } on TimeoutException {
      throw const DeepseekException('The request timed out.');
    } catch (error) {
      throw DeepseekException(error.toString());
    }
  }

  static void _injectIdentity(List<Map<String, dynamic>> messages) {
    const reminder =
        'Reminder: out of character, your real identity is DeepSeek. '
        'In-character role-play is allowed, but the underlying model does '
        'not actually change.';
    if (messages.isNotEmpty && messages.first['role'] == 'system') {
      final current = messages.first['content'];
      if (current is String && current.trim().isNotEmpty) {
        messages.first['content'] =
            '$identityPrompt\n\n$openRoleplayPrompt\n\n'
            '${current.trim()}\n\n$reminder';
        return;
      }
    }
    messages.insert(0, {
      'role': 'system',
      'content': '$identityPrompt\n\n$openRoleplayPrompt\n\n$reminder',
    });
  }

  /// Builds an OpenAI-compatible multimodal message. Local images are
  /// downscaled and sent as base64 data URLs so vision-capable endpoints can
  /// understand screenshots, photos and handwritten notes.
  static Future<Map<String, dynamic>> _encodeMessage(
    DeepseekMessage message,
  ) async {
    final text = message.content.trim();
    final imageParts = <Map<String, dynamic>>[];
    for (final path in message.imagePaths) {
      final part = await _encodeImagePart(path);
      if (part != null) imageParts.add(part);
    }
    if (imageParts.isEmpty) {
      return {'role': message.role, 'content': text};
    }
    final content = <Map<String, dynamic>>[
      if (text.isNotEmpty) {'type': 'text', 'text': text},
      ...imageParts,
    ];
    return {'role': message.role, 'content': content};
  }

  static Future<Map<String, dynamic>?> _encodeImagePart(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final originalBytes = await file.readAsBytes();
      if (originalBytes.isEmpty) return null;

      var bytes = originalBytes;
      final decoded = img.decodeImage(originalBytes);
      if (decoded != null) {
        final image = decoded;
        const maxDimension = 1600;
        if (image.width > maxDimension || image.height > maxDimension) {
          final resized = image.width >= image.height
              ? img.copyResize(image, width: maxDimension)
              : img.copyResize(image, height: maxDimension);
          bytes = Uint8List.fromList(img.encodeJpg(resized, quality: 85));
        } else if (image.hasAlpha) {
          bytes = Uint8List.fromList(img.encodeJpg(image, quality: 88));
        }
      }

      final mime = bytes == originalBytes ? _imageMime(path) : 'image/jpeg';
      return {
        'type': 'image_url',
        'image_url': {'url': 'data:$mime;base64,${base64Encode(bytes)}'},
      };
    } catch (_) {
      return null;
    }
  }

  static String _imageMime(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  /// Cheap round-trip used by the settings page.
  static Future<void> testConnection(DeepseekConfig config) async {
    await complete(
      config: config,
      messages: const [
        DeepseekMessage(role: 'user', content: 'Say "ok" in one word.'),
      ],
      temperature: 0,
      maxTokens: 8,
      timeout: const Duration(seconds: 20),
    );
  }

  static Uri _endpoint(String baseUrl) {
    var base = baseUrl.trim();
    if (base.isEmpty) base = DeepseekConfig.defaultBaseUrl;
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.endsWith('/chat/completions')) return Uri.parse(base);
    return Uri.parse('$base/chat/completions');
  }

  static String _extractError(String body, int statusCode) {
    return formatApiHttpError(statusCode: statusCode, body: body);
  }
}
