import 'dart:convert';

import 'package:http/http.dart' as http;

/// Minimal client for the Kivo Wiki public data API.
///
/// The student detail endpoint exposes the gallery used by the website at
/// "鉴赏 -> 角色画廊 -> 初始立绘差分".  The API occasionally returns image URLs
/// with a protocol-relative prefix, so all URLs are normalized before use.
class KivoGalleryService {
  KivoGalleryService._();

  static const String _host = 'https://api.kivo.wiki';
  static const int _studentPageSize = 1000;

  static List<KivoStudent>? _studentCache;
  static final Map<int, List<String>> _galleryCache = <int, List<String>>{};

  static String _normalizeUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('//')) return 'https:$value';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) return 'https://static.kivo.wiki$value';
    return 'https://static.kivo.wiki/$value';
  }

  static String _normalizeName(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');

  static Future<List<KivoStudent>> _loadStudents() async {
    final cached = _studentCache;
    if (cached != null) return cached;

    final uri = Uri.parse(
      '$_host/api/v1/data/students/?page=1&page_size=$_studentPageSize',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Kivo API returned ${response.statusCode}');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final data = decoded['data'] as Map<String, dynamic>?;
    final rawStudents = data?['students'] as List<dynamic>? ?? const [];
    final students = <KivoStudent>[];
    for (final item in rawStudents) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final id = (map['id'] as num?)?.toInt() ?? 0;
      final family = map['family_name']?.toString() ?? '';
      final given = map['given_name']?.toString() ?? '';
      final skin = map['skin']?.toString() ?? '';
      final displayName = '$family$given'.trim();
      if (id <= 0 || displayName.isEmpty) continue;
      students.add(
        KivoStudent(
          id: id,
          displayName: displayName,
          familyName: family,
          givenName: given,
          skin: skin,
          avatarUrl: _normalizeUrl(map['avatar']?.toString() ?? ''),
        ),
      );
    }
    _studentCache = students;
    return students;
  }

  static int? _findStudentId(List<KivoStudent> students, String studentName) {
    final target = _normalizeName(studentName);
    if (target.isEmpty) return null;

    KivoStudent? best;
    var bestScore = 0;
    for (final student in students) {
      final family = _normalizeName(student.familyName);
      final given = _normalizeName(student.givenName);
      final full = _normalizeName(student.displayName);
      final skin = _normalizeName(student.skin);
      var score = 0;
      if (full == target) {
        score = 100;
      } else if ('$given$family' == target) {
        score = 90;
      } else if (given.isNotEmpty && target.contains(given)) {
        score = 60;
      } else if (family.isNotEmpty && target.contains(family)) {
        score = 40;
      }
      if (score > 0) {
        // Prefer the default skin when several records share a name.
        if (skin.isEmpty) score += 5;
        if (score > bestScore) {
          bestScore = score;
          best = student;
        }
      }
    }
    return best?.id;
  }

  static Future<int?> resolveStudentId({
    required String studentName,
    int studentId = 0,
  }) async {
    if (studentId > 0) return studentId;
    final students = await _loadStudents();
    return _findStudentId(students, studentName);
  }

  static Future<List<String>> initialPortraitVariants({
    required String studentName,
    int studentId = 0,
  }) async {
    final resolvedId = await resolveStudentId(
      studentName: studentName,
      studentId: studentId,
    );
    if (resolvedId == null) return const <String>[];
    final cached = _galleryCache[resolvedId];
    if (cached != null) return cached;

    final uri = Uri.parse('$_host/api/v1/data/students/$resolvedId/');
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Kivo API returned ${response.statusCode}');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final data = decoded['data'] as Map<String, dynamic>?;
    final rawGallery = data?['gallery'] as List<dynamic>? ?? const [];
    final images = <String>[];
    for (final entry in rawGallery) {
      if (entry is! Map) continue;
      final title = entry['title']?.toString() ?? '';
      if (title.contains('初始立绘差分') || title.contains('初始立绘')) {
        final rawImages = entry['images'] as List<dynamic>? ?? const [];
        for (final image in rawImages) {
          final normalized = _normalizeUrl(image.toString());
          if (normalized.isNotEmpty) images.add(normalized);
        }
        if (images.isNotEmpty) break;
      }
    }
    // Some students do not have the named gallery but still expose the first
    // image set in the response.  Use that as a graceful fallback.
    if (images.isEmpty) {
      for (final entry in rawGallery) {
        if (entry is! Map) continue;
        final rawImages = entry['images'] as List<dynamic>? ?? const [];
        for (final image in rawImages) {
          final normalized = _normalizeUrl(image.toString());
          if (normalized.isNotEmpty) images.add(normalized);
        }
        if (images.isNotEmpty) break;
      }
    }
    _galleryCache[resolvedId] = images;
    return images;
  }
}

class KivoStudent {
  const KivoStudent({
    required this.id,
    required this.displayName,
    required this.familyName,
    required this.givenName,
    required this.skin,
    required this.avatarUrl,
  });

  final int id;
  final String displayName;
  final String familyName;
  final String givenName;
  final String skin;
  final String avatarUrl;
}
