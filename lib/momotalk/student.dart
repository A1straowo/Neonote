// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart';
import 'package:neonote/momotalk/mochat.dart';
import 'package:neonote/services/platform_media.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/widgets/cached_student_avatar.dart';
import 'package:neonote/widgets/image_source_view.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BuiltInStudent {
  final int id;
  final String name;
  final String familyName;
  final String givenName;
  final String avatarUrl;

  const BuiltInStudent({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.familyName = '',
    this.givenName = '',
  });

  String get displayName => studentDisplayName(
    fullName: name,
    familyName: familyName,
    givenName: givenName,
  );

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'family_name': familyName,
      'given_name': givenName,
      'avatar_url': avatarUrl,
    };
  }

  factory BuiltInStudent.fromMap(Map<dynamic, dynamic> map) {
    return BuiltInStudent(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name']?.toString() ?? '',
      familyName: map['family_name']?.toString() ?? '',
      givenName: map['given_name']?.toString() ?? '',
      avatarUrl: map['avatar_url']?.toString() ?? '',
    );
  }
}

class CustomStudent {
  final int id;
  final String name;
  final String familyName;
  final String givenName;
  final String avatarUrl;
  final int createdAt;

  const CustomStudent({
    required this.id,
    required this.name,
    this.familyName = '',
    this.givenName = '',
    this.avatarUrl = '',
    required this.createdAt,
  });

  String get displayName => studentDisplayName(
    fullName: name,
    familyName: familyName,
    givenName: givenName,
  );

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'family_name': familyName,
      'given_name': givenName,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
    };
  }

  factory CustomStudent.fromMap(Map<dynamic, dynamic> map) {
    final normalizedName = map['name']?.toString() ?? '';
    return CustomStudent(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: normalizedName,
      familyName: map['family_name']?.toString() ?? '',
      givenName: map['given_name']?.toString() ?? '',
      avatarUrl:
          map['avatar_url']?.toString() ?? map['avatarUrl']?.toString() ?? '',
      createdAt:
          (map['created_at'] as num?)?.toInt() ??
          (map['createdAt'] as num?)?.toInt() ??
          0,
    );
  }
}

class CustomStudentRepository {
  static const String _customTable = 'custom_students';
  static const String _builtInTable = 'built_in_students';
  static const String _hiveKey = 'custom_students';
  static const String _builtInHiveKey = 'built_in_students';
  static Database? _database;
  static bool _databaseUnavailable = false;

  static Future<Database?> _openDatabase() async {
    if (_databaseUnavailable) return null;
    if (_database != null) return _database;
    try {
      final databasePath = await getDatabasesPath();
      _database = await openDatabase(
        p.join(databasePath, 'neonote_custom_students.db'),
        version: 3,
        onCreate: (db, version) async {
          await _createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'CREATE TABLE IF NOT EXISTS $_builtInTable ('
              'id INTEGER PRIMARY KEY,'
              'name TEXT NOT NULL,'
              'avatar_url TEXT NOT NULL DEFAULT "",'
              'position INTEGER NOT NULL DEFAULT 0)',
            );
          }
          if (oldVersion < 3) {
            await _addColumnIfMissing(
              db,
              _builtInTable,
              'family_name',
              'TEXT NOT NULL DEFAULT ""',
            );
            await _addColumnIfMissing(
              db,
              _builtInTable,
              'given_name',
              'TEXT NOT NULL DEFAULT ""',
            );
            await _addColumnIfMissing(
              db,
              _customTable,
              'family_name',
              'TEXT NOT NULL DEFAULT ""',
            );
            await _addColumnIfMissing(
              db,
              _customTable,
              'given_name',
              'TEXT NOT NULL DEFAULT ""',
            );
          }
        },
      );
      return _database;
    } catch (_) {
      _databaseUnavailable = true;
      return null;
    }
  }

  static Future<void> _createTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_customTable ('
      'id INTEGER PRIMARY KEY,'
      'name TEXT NOT NULL,'
      'family_name TEXT NOT NULL DEFAULT "",'
      'given_name TEXT NOT NULL DEFAULT "",'
      'avatar_url TEXT NOT NULL DEFAULT "",'
      'created_at INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $_builtInTable ('
      'id INTEGER PRIMARY KEY,'
      'name TEXT NOT NULL,'
      'family_name TEXT NOT NULL DEFAULT "",'
      'given_name TEXT NOT NULL DEFAULT "",'
      'avatar_url TEXT NOT NULL DEFAULT "",'
      'position INTEGER NOT NULL DEFAULT 0)',
    );
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    try {
      final rows = await db.rawQuery('PRAGMA table_info($table)');
      final exists = rows.any((row) => row['name']?.toString() == column);
      if (!exists) {
        await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
      }
    } catch (_) {}
  }

  static Future<List<CustomStudent>> loadAll() async {
    final database = await _openDatabase();
    if (database != null) {
      try {
        final rows = await database.query(
          _customTable,
          orderBy: 'created_at ASC',
        );
        return rows.map(CustomStudent.fromMap).toList();
      } catch (_) {}
    }
    return _loadFromHive();
  }

  static Future<void> upsert(CustomStudent student) async {
    final database = await _openDatabase();
    if (database != null) {
      try {
        await database.insert(
          _customTable,
          student.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return;
      } catch (_) {}
    }
    final box = Hive.box(themeBox);
    final students = _loadFromHive();
    final index = students.indexWhere((item) => item.id == student.id);
    if (index >= 0) {
      students[index] = student;
    } else {
      students.add(student);
    }
    await box.put(_hiveKey, students.map((item) => item.toMap()).toList());
  }

  static Future<void> delete(int id) async {
    final database = await _openDatabase();
    if (database != null) {
      try {
        await database.delete(_customTable, where: 'id = ?', whereArgs: [id]);
        return;
      } catch (_) {}
    }
    final box = Hive.box(themeBox);
    final students = _loadFromHive()..removeWhere((item) => item.id == id);
    await box.put(_hiveKey, students.map((item) => item.toMap()).toList());
  }

  static Future<List<BuiltInStudent>> loadBuiltIns() async {
    final database = await _openDatabase();
    if (database != null) {
      try {
        final rows = await database.query(
          _builtInTable,
          orderBy: 'position ASC, id ASC',
        );
        if (rows.isNotEmpty) {
          return rows.map(BuiltInStudent.fromMap).toList();
        }
      } catch (_) {}
    }
    return _loadBuiltInsFromHive();
  }

  static Future<void> saveBuiltIns(List<BuiltInStudent> students) async {
    final database = await _openDatabase();
    if (database != null) {
      try {
        await database.transaction((txn) async {
          await txn.delete(_builtInTable);
          final batch = txn.batch();
          for (var index = 0; index < students.length; index++) {
            final student = students[index];
            batch.insert(_builtInTable, {
              'id': student.id,
              'name': student.name,
              'family_name': student.familyName,
              'given_name': student.givenName,
              'avatar_url': student.avatarUrl,
              'position': index,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
          await batch.commit(noResult: true);
        });
        return;
      } catch (_) {}
    }
    await Hive.box(
      themeBox,
    ).put(_builtInHiveKey, students.map((item) => item.toMap()).toList());
  }

  static List<CustomStudent> _loadFromHive() {
    try {
      final raw = Hive.box(themeBox).get(_hiveKey, defaultValue: <dynamic>[]);
      if (raw is List) {
        return raw.whereType<Map>().map(CustomStudent.fromMap).toList();
      }
    } catch (_) {}
    return <CustomStudent>[];
  }

  static List<BuiltInStudent> _loadBuiltInsFromHive() {
    try {
      final raw = Hive.box(
        themeBox,
      ).get(_builtInHiveKey, defaultValue: <dynamic>[]);
      if (raw is List) {
        return raw.whereType<Map>().map(BuiltInStudent.fromMap).toList();
      }
    } catch (_) {}
    return <BuiltInStudent>[];
  }
}

class StudentPickerPage extends StatefulWidget {
  const StudentPickerPage({super.key});

  @override
  State<StudentPickerPage> createState() => _StudentPickerPageState();
}

class _StudentPickerPageState extends State<StudentPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  int _tabIndex = 0;
  List<CustomStudent> _customStudents = <CustomStudent>[];
  bool _customLoading = true;
  Future<List<BuiltInStudent>>? _builtInFuture;
  static const int _builtInDataVersion = 3;

  @override
  void initState() {
    super.initState();
    _builtInFuture = _loadBuiltInStudents();
    _loadCustomStudents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  String _normalizeSearch(String value) {
    return value.trim().toLowerCase().replaceAll(
      RegExp(r'[\s\u3000·・,，.。_\-]+'),
      '',
    );
  }

  bool _matchesSearch(String query, List<String> values) {
    final normalized = _normalizeSearch(query);
    if (normalized.isEmpty) return true;
    return values.any((value) => _normalizeSearch(value).contains(normalized));
  }

  Future<void> _loadCustomStudents() async {
    final students = await CustomStudentRepository.loadAll();
    if (!mounted) return;
    setState(() {
      _customStudents = students;
      _customLoading = false;
    });
  }

  Future<List<BuiltInStudent>> _loadBuiltInStudents({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await CustomStudentRepository.loadBuiltIns();
      final rawVersion = Hive.box(
        themeBox,
      ).get('built_in_data_version', defaultValue: 0);
      final cachedVersion = rawVersion is int
          ? rawVersion
          : (rawVersion is num ? rawVersion.toInt() : 0);
      if (cached.isNotEmpty && cachedVersion >= _builtInDataVersion) {
        return cached;
      }
    }
    final students = await _fetchBuiltInStudents();
    await CustomStudentRepository.saveBuiltIns(students);
    await Hive.box(themeBox).put('built_in_data_version', _builtInDataVersion);
    return students;
  }

  void _refreshBuiltIns() {
    setState(() {
      _builtInFuture = _loadBuiltInStudents(forceRefresh: true);
    });
  }

  Future<List<BuiltInStudent>> _fetchBuiltInStudents() async {
    try {
      final uri = Uri.parse(
        'https://api.kivo.wiki/api/v1/data/students?page=1&page_size=1000',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Kivo API returned ${response.statusCode}');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final data = decoded['data'] as Map<String, dynamic>?;
      final rawStudents = data?['students'] as List<dynamic>?;
      if (rawStudents == null || rawStudents.isEmpty) {
        throw Exception('Kivo API returned no students');
      }
      final seenNames = <String>{};
      final students = <BuiltInStudent>[];
      for (final item in rawStudents) {
        final map = item as Map<String, dynamic>;
        final avatar = map['avatar']?.toString() ?? '';
        if (avatar.isEmpty) continue;
        final isDefaultSkin =
            (map['skin']?.toString() ?? '').isEmpty &&
            (map['skin_jp']?.toString() ?? '').isEmpty &&
            (map['skin_cn']?.toString() ?? '').isEmpty &&
            (map['skin_zh_tw']?.toString() ?? '').isEmpty;
        if (!isDefaultSkin) continue;
        final familyName = _firstStringValue(map, const [
          'family_name',
          'family_name_zh',
          'family_name_cn',
          'familyName',
        ]);
        final givenName = _firstStringValue(map, const [
          'given_name',
          'given_name_zh',
          'given_name_cn',
          'givenName',
        ]);
        final fullName = _firstStringValue(map, const [
          'name',
          'display_name',
          'full_name',
        ]);
        final name = fullName.isNotEmpty
            ? fullName
            : '$familyName$givenName'.trim();
        if (name.isEmpty || !seenNames.add(name)) continue;
        students.add(
          BuiltInStudent(
            id: (map['id'] as num?)?.toInt() ?? 0,
            name: name,
            familyName: familyName,
            givenName: givenName,
            avatarUrl: _normalizeAvatar(avatar),
          ),
        );
      }
      if (students.isEmpty) {
        throw Exception('Kivo API returned no usable students');
      }
      return students;
    } catch (_) {
      return _fallbackBuiltInStudents;
    }
  }

  String _firstStringValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _normalizeAvatar(String url) {
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('http')) return url;
    return 'https://static.kivo.wiki$url';
  }

  Future<void> _showAddStudentDialog() async {
    final student = await showDialog<CustomStudent>(
      context: context,
      builder: (_) => const _AddCustomStudentDialog(),
    );
    if (student == null) return;
    await CustomStudentRepository.upsert(student);
    await _loadCustomStudents();
  }

  Future<void> _confirmDeleteStudent(CustomStudent student) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(l10n.delete),
        content: Text(student.displayName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await CustomStudentRepository.delete(student.id);
    await _loadCustomStudents();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.select_student,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: colorScheme.onSurface,
            fontSize: DeviceInfo.pt(20),
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: DeviceInfo.pt(12)),
          CapsuleStyle1(
            initialIndex: _tabIndex,
            options: [l10n.built_in, l10n.custom],
            onChanged: (index) {
              setState(() => _tabIndex = index);
            },
          ),
          SizedBox(height: DeviceInfo.pt(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DeviceInfo.pt(16)),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.search_students,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clear,
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          SizedBox(height: DeviceInfo.pt(8)),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [_buildBuiltInTab(context), _buildCustomTab(context)],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton(
              onPressed: _showAddStudentDialog,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.person_add_alt_1),
            )
          : null,
    );
  }

  Widget _buildBuiltInTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<BuiltInStudent>>(
      future: _builtInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final students = (snapshot.data ?? _fallbackBuiltInStudents)
            .where(
              (student) => _matchesSearch(_searchController.text, [
                student.name,
                student.familyName,
                student.givenName,
                student.displayName,
              ]),
            )
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                DeviceInfo.pt(20),
                DeviceInfo.pt(8),
                DeviceInfo.pt(20),
                DeviceInfo.pt(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.character,
                      style: TextStyle(
                        fontFamily: 'ResourceHanCN',
                        fontSize: DeviceInfo.pt(18),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshBuiltIns,
                    tooltip: AppLocalizations.of(context)!.retry,
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
            Expanded(
              child:
                  students.isEmpty && _searchController.text.trim().isNotEmpty
                  ? Center(child: Text(l10n.no_student_matches))
                  : GridView.builder(
                      padding: EdgeInsets.all(DeviceInfo.pt(16)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (MediaQuery.sizeOf(context).width / 92)
                            .floor()
                            .clamp(3, 6),
                        childAspectRatio: 0.82,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: students.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _AvatarCircle(
                            name: '',
                            onTap: () => Navigator.pop(context),
                          );
                        }
                        final student = students[index - 1];
                        return _AvatarCircle(
                          name: student.displayName,
                          imageUrl: student.avatarUrl,
                          tooltip: student.displayName,
                          onTap: () => Navigator.pop(context, student),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_customLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final filteredStudents = _customStudents
        .where(
          (student) => _matchesSearch(_searchController.text, [
            student.name,
            student.familyName,
            student.givenName,
            student.displayName,
          ]),
        )
        .toList();
    if (filteredStudents.isEmpty &&
        _searchController.text.trim().isNotEmpty &&
        _customStudents.isNotEmpty) {
      return Center(child: Text(l10n.no_student_matches));
    }
    if (_customStudents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(DeviceInfo.pt(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add_alt_1,
                size: DeviceInfo.pt(52),
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              SizedBox(height: DeviceInfo.pt(12)),
              Text(
                l10n.no_custom_students,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        DeviceInfo.pt(16),
        DeviceInfo.pt(16),
        DeviceInfo.pt(16),
        DeviceInfo.pt(88),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (MediaQuery.sizeOf(context).width / 92).floor().clamp(
          3,
          6,
        ),
        childAspectRatio: 0.82,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _AvatarCircle(
          name: student.displayName,
          imageUrl: student.avatarUrl,
          tooltip: student.displayName,
          onTap: () => Navigator.pop(context, student),
          onLongPress: () => _confirmDeleteStudent(student),
        );
      },
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String? tooltip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _AvatarCircle({
    required this.name,
    this.imageUrl,
    this.tooltip,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = name.trim();
    Widget avatar = imageUrl == null || imageUrl!.isEmpty
        ? _fallbackAvatar(context)
        : CachedStudentAvatar(
            source: imageUrl!,
            fit: BoxFit.cover,
            placeholder: _fallbackAvatar(context),
            error: _fallbackAvatar(context),
          );

    if (tooltip != null && tooltip!.isNotEmpty) {
      avatar = Tooltip(message: tooltip!, child: avatar);
    }

    return Semantics(
      container: true,
      button: true,
      label: displayName.isEmpty ? l10n.cancel : '${l10n.student}：$displayName',
      onTap: onTap,
      onLongPress: onLongPress,
      child: ExcludeSemantics(
        child: Column(
          children: [
            Expanded(
              child: Material(
                color: colorScheme.onSurface.withOpacity(0.06),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  customBorder: const CircleBorder(),
                  child: avatar,
                ),
              ),
            ),
            if (displayName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 11,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmedName = name.trim();
    final firstChar = trimmedName.isEmpty ? null : trimmedName.substring(0, 1);
    if (firstChar == null) {
      return Icon(
        Icons.question_mark,
        color: colorScheme.onSurface.withOpacity(0.6),
        size: 28,
      );
    }
    return Container(
      color: colorScheme.primary.withOpacity(0.16),
      alignment: Alignment.center,
      child: Text(
        firstChar,
        style: TextStyle(
          fontFamily: 'ResourceHanCN',
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _AddCustomStudentDialog extends StatefulWidget {
  const _AddCustomStudentDialog();

  @override
  State<_AddCustomStudentDialog> createState() =>
      _AddCustomStudentDialogState();
}

class _AddCustomStudentDialogState extends State<_AddCustomStudentDialog> {
  late final TextEditingController _idController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _givenNameController;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(
      text: (100000 + math.Random().nextInt(900000)).toString(),
    );
    _familyNameController = TextEditingController();
    _givenNameController = TextEditingController();
  }

  @override
  void dispose() {
    _idController.dispose();
    _familyNameController.dispose();
    _givenNameController.dispose();
    super.dispose();
  }

  void _save() {
    final id = int.tryParse(_idController.text.trim());
    final familyName = _familyNameController.text.trim();
    final givenName = _givenNameController.text.trim();
    final name = '$familyName$givenName'.trim();
    if (id == null || name.isEmpty) return;
    Navigator.pop(
      context,
      CustomStudent(
        id: id,
        name: name,
        familyName: familyName,
        givenName: givenName,
        avatarUrl: _avatarUrl.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    if (!PlatformMediaService.isMobile) {
      _toast(l10n.image_pick_failed);
      return;
    }
    final path = await PlatformMediaService.pickImageFromGallery();
    if (!mounted || path == null) return;
    setState(() => _avatarUrl = path);
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DeviceInfo.pt(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.add_custom_student,
              style: TextStyle(
                fontFamily: 'ResourceHanCN',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: DeviceInfo.pt(24)),
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.id,
                border: const UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: DeviceInfo.pt(20)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _familyNameController,
                    decoration: const InputDecoration(
                      labelText: '姓',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: DeviceInfo.pt(16)),
                Expanded(
                  child: TextField(
                    controller: _givenNameController,
                    decoration: const InputDecoration(
                      labelText: '名',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DeviceInfo.pt(24)),
            Row(
              children: [
                Container(
                  width: DeviceInfo.pt(84),
                  height: DeviceInfo.pt(84),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _avatarUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: DeviceInfo.pt(48),
                          color: colorScheme.onSurface.withOpacity(0.4),
                        )
                      : SourceImageView(
                          source: _avatarUrl,
                          fit: BoxFit.cover,
                          error: Icon(
                            Icons.broken_image_outlined,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                ),
                SizedBox(width: DeviceInfo.pt(12)),
                IconButton(
                  onPressed: _pickAvatar,
                  tooltip: l10n.pick_from_gallery,
                  icon: const Icon(Icons.image_outlined),
                ),
                const Spacer(),
                TextButton(onPressed: _save, child: Text(l10n.save)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const List<BuiltInStudent> _fallbackBuiltInStudents = <BuiltInStudent>[
  BuiltInStudent(
    id: 1,
    name: '圣园未花',
    familyName: '圣园',
    givenName: '未花',
    avatarUrl:
        'https://static.kivo.wiki/images/students/%E5%9C%A3%E5%9B%AD%E6%9C%AA%E8%8A%B1/avatar.png',
  ),
  BuiltInStudent(
    id: 76,
    name: '小鸟游星野',
    familyName: '小鸟游',
    givenName: '星野',
    avatarUrl:
        'https://static.kivo.wiki/images/students/%E5%B0%8F%E9%B8%9F%E6%B8%B8%20%E6%98%9F%E9%87%8E/avatar.png',
  ),
  BuiltInStudent(
    id: 86,
    name: '砂狼白子',
    familyName: '砂狼',
    givenName: '白子',
    avatarUrl:
        'https://static.kivo.wiki/images/students/%E7%A0%82%E7%8B%BC%20%E7%99%BD%E5%AD%90/avatar.png',
  ),
  BuiltInStudent(
    id: 85,
    name: '奥空绫音',
    familyName: '奥空',
    givenName: '绫音',
    avatarUrl:
        'https://static.kivo.wiki/images/students/%E5%A5%A5%E7%A9%BA%20%E7%BB%AB%E9%9F%B3/avatar.png',
  ),
  BuiltInStudent(
    id: 78,
    name: '十六夜野宫',
    familyName: '十六夜',
    givenName: '野宫',
    avatarUrl:
        'https://static.kivo.wiki/images/students/%E5%8D%81%E5%85%AD%E5%A4%9C%20%E9%87%8E%E5%AE%AB/avatar.png',
  ),
  BuiltInStudent(
    id: 71,
    name: '空崎日奈',
    familyName: '空崎',
    givenName: '日奈',
    avatarUrl:
        'https://static.kivo.wiki/images/students/%E7%A9%BA%E5%B4%8E%20%E6%97%A5%E5%A5%88/avatar.png',
  ),
];
