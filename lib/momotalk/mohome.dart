// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neonote/deepseek/ai_chat_page.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show DeviceInfo, themeBox;
import 'package:neonote/momotalk/mochat.dart';
import 'package:neonote/momotalk/student.dart';
import 'package:neonote/services/deepseek_service.dart';
import 'package:neonote/services/gesture_settings.dart';
import 'package:neonote/services/kivo_gallery_service.dart';
import 'package:neonote/services/platform_media.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/ui/app_layout.dart';
import 'package:neonote/widgets/app_drawer.dart';
import 'package:neonote/widgets/ball_actions.dart';
import 'package:neonote/widgets/floating_ball.dart';
import 'package:neonote/widgets/deepseek_icon.dart';
import 'package:neonote/widgets/image_source_view.dart';
import 'package:path_provider/path_provider.dart';

class MoHomePage extends StatefulWidget {
  const MoHomePage({super.key});

  static const String routeName = '/momotalk';

  @override
  State<MoHomePage> createState() => _MoHomePageState();
}

class _MoHomePageState extends State<MoHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openAiChat(AppLocalizations l10n) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiChatPage(
          title: l10n.ai_assistant,
          welcome: l10n.ai_welcome,
          systemPrompt:
              'You are a flexible Deepseek assistant in MomoTalk. Reply warmly, '
              'help with conversations, everyday topics, ideas and requested '
              'role-play, and keep Deepseek as your underlying identity.',
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NoteStore.ensureGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: FaIcon(
              FontAwesomeIcons.bars,
              color: scheme.onSurface,
              size: DeviceInfo.pt(20),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: Text(
          'MomoTalk',
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: scheme.onSurface,
            fontSize: DeviceInfo.pt(25),
          ),
        ),
        backgroundColor: scheme.surface,
        actions: [
          IconButton(
            tooltip: l10n.ai_chat,
            onPressed: () => _openAiChat(l10n),
            icon: DeepseekIcon(
              color: scheme.onSurface,
              size: DeviceInfo.pt(20),
            ),
          ),
        ],
      ),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: DeviceInfo.pt(125),
      drawer: const AppDrawer(activePage: AppDrawerPage.momoTalk),
      body: Stack(
        children: [
          Positioned.fill(
            child: ValueListenableBuilder<int>(
              valueListenable: NoteStore.chatsRevision,
              builder: (context, _, _) {
                final groups = NoteStore.groups();
                final chatsByGroup = <String, List<MoChat>>{};
                for (final chat in NoteStore.activeChats()) {
                  (chatsByGroup[chat.groupId] ??= <MoChat>[]).add(chat);
                }

                for (final chats in chatsByGroup.values) {
                  chats.sort((a, b) {
                    if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
                    return b.updatedAt.compareTo(a.updatedAt);
                  });
                }
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    DeviceInfo.pt(12),
                    DeviceInfo.pt(8),
                    DeviceInfo.pt(12),
                    DeviceInfo.pt(150),
                  ),
                  children: [
                    for (final group in groups)
                      _buildGroupCard(
                        context,
                        group,
                        chatsByGroup[group.id] ?? const <MoChat>[],
                      ),
                  ],
                );
              },
            ),
          ),
          FloatingBallMenu(items: buildMomotalkBallItems(context)),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    MoGroup group,
    List<MoChat> chats,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              DeviceInfo.pt(8),
              DeviceInfo.pt(group.expanded ? 10 : 8),
              DeviceInfo.pt(8),
              DeviceInfo.pt(group.expanded ? 0 : 8),
            ),
            child: Row(
              children: [
                _buildGroupMenu(context, l10n, group, scheme),
                Expanded(
                  child: Text(
                    group.name.isEmpty ? l10n.default_group : group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ResourceHanCN',
                      fontSize: DeviceInfo.pt(22),
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      NoteStore.setGroupExpanded(group.id, !group.expanded),
                  icon: _chevron(context, group.expanded),
                ),
              ],
            ),
          ),
          if (group.expanded) ...[
            if (chats.isEmpty)
              _emptyRow(context, l10n.no_chats_in_group)
            else
              for (final chat in chats) _buildChatRow(context, chat),
            SizedBox(height: DeviceInfo.pt(6)),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupMenu(
    BuildContext context,
    AppLocalizations l10n,
    MoGroup group,
    ColorScheme scheme,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.menu, size: DeviceInfo.pt(22), color: scheme.onSurface),
      tooltip: l10n.rename,
      position: PopupMenuPosition.under,
      onSelected: (value) {
        if (value == 'rename') {
          _renameGroup(context, l10n, group);
        } else if (value == 'delete') {
          _deleteGroup(context, l10n, group);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'rename',
          child: Text(
            l10n.rename,
            style: const TextStyle(fontFamily: 'ResourceHanCN'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            l10n.delete,
            style: const TextStyle(fontFamily: 'ResourceHanCN'),
          ),
        ),
      ],
    );
  }

  Widget _buildChatRow(BuildContext context, MoChat chat) {
    final scheme = Theme.of(context).colorScheme;
    final rightAction = GestureSettings.rightAction;
    final leftAction = GestureSettings.leftAction;

    final row = InkWell(
      onTap: () => _openChat(context, chat),
      onLongPress: () => _deleteChat(context, chat),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          DeviceInfo.pt(14),
          DeviceInfo.pt(8),
          DeviceInfo.pt(14),
          DeviceInfo.pt(8),
        ),
        child: Row(
          children: [
            _MoAvatar(
              name: chat.displayName,
              imageUrl: chat.avatarUrl,
              size: DeviceInfo.pt(48),
            ),
            SizedBox(width: DeviceInfo.pt(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (chat.pinned)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.push_pin,
                            size: DeviceInfo.pt(15),
                            color: scheme.primary,
                          ),
                        ),
                      if (chat.marked)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.flag,
                            size: DeviceInfo.pt(15),
                            color: Colors.purple,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'ResourceHanCN',
                            fontSize: DeviceInfo.pt(17),
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (chat.lastMessage.isNotEmpty) ...[
                    SizedBox(height: DeviceInfo.pt(2)),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ResourceHanCN',
                        fontSize: DeviceInfo.pt(14),
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('chat_${chat.id}'),
      direction: DismissDirection.horizontal,
      background: _chatGestureBackground(rightAction, Alignment.centerLeft),
      secondaryBackground: _chatGestureBackground(
        leftAction,
        Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        final action = direction == DismissDirection.startToEnd
            ? rightAction
            : leftAction;
        await _applyChatGesture(context, chat, action);
        return false;
      },
      child: row,
    );
  }

  Widget _chatGestureBackground(GestureAction action, Alignment alignment) {
    final l10n = AppLocalizations.of(context)!;
    final color = switch (action) {
      GestureAction.pin => Colors.blue,
      GestureAction.archive => Colors.orange,
      GestureAction.mark => Colors.purple,
      GestureAction.delete => Colors.red,
    };

    final icon = switch (action) {
      GestureAction.pin => Icons.push_pin,
      GestureAction.archive => Icons.archive_outlined,
      GestureAction.mark => Icons.flag_outlined,
      GestureAction.delete => Icons.delete_outline,
    };

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            action.label(l10n),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyChatGesture(
    BuildContext context,
    MoChat chat,
    GestureAction action,
  ) async {
    switch (action) {
      case GestureAction.pin:
        await NoteStore.setChatPinned(chat.id, !chat.pinned);
        return;
      case GestureAction.archive:
        await NoteStore.setChatArchived(chat.id, true);
        return;
      case GestureAction.mark:
        await NoteStore.setChatMarked(chat.id, !chat.marked);
        return;
      case GestureAction.delete:
        await _deleteChat(context, chat);
        return;
    }
  }

  void _openChat(BuildContext context, MoChat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoChatDetailPage(
          chatId: chat.id,
          title: chat.name,
          familyName: chat.familyName,
          givenName: chat.givenName,
          familyNames: chat.familyNames,
          givenNames: chat.givenNames,
          fullNames: chat.fullNames,
          avatarUrl: chat.avatarUrl,
          studentId: chat.studentId,
        ),
      ),
    );
  }

  Future<void> _renameGroup(
    BuildContext context,
    AppLocalizations l10n,
    MoGroup group,
  ) async {
    final name = await showTextInputDialog(
      context,
      title: l10n.rename,
      hint: l10n.input_name_hint,
      confirmLabel: l10n.confirm,
      initialValue: group.name,
    );
    if (name == null || name.isEmpty) return;
    await NoteStore.renameGroup(group.id, name);
  }

  Future<void> _deleteGroup(
    BuildContext context,
    AppLocalizations l10n,
    MoGroup group,
  ) async {
    final confirmed = await _confirm(
      context,
      l10n.delete,
      l10n.group_delete_confirm(
        group.name.isEmpty ? l10n.default_group : group.name,
      ),
      l10n,
    );
    if (!confirmed) return;
    await NoteStore.deleteGroup(group.id);
  }

  Future<void> _deleteChat(BuildContext context, MoChat chat) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      context,
      l10n.delete,
      l10n.chat_delete_confirm(chat.name),
      l10n,
    );
    if (!confirmed) return;
    await NoteStore.deleteChat(chat.id);
  }

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String message,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontFamily: 'ResourceHanCN')),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'ResourceHanCN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(fontFamily: 'ResourceHanCN'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.confirm,
              style: const TextStyle(fontFamily: 'ResourceHanCN'),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: DeviceInfo.pt(14)),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(DeviceInfo.pt(22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _chevron(BuildContext context, bool expanded) {
    return AnimatedRotation(
      turns: expanded ? 0.5 : 0,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        Icons.keyboard_arrow_down,
        size: DeviceInfo.pt(26),
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _emptyRow(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DeviceInfo.pt(20),
        DeviceInfo.pt(4),
        DeviceInfo.pt(20),
        DeviceInfo.pt(18),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'ResourceHanCN',
          fontSize: DeviceInfo.pt(15),
          color: scheme.onSurface.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

class _MoAvatar extends StatelessWidget {
  const _MoAvatar({
    required this.name,
    required this.imageUrl,
    required this.size,
  });

  final String name;
  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? _fallback(scheme)
            : SourceImageView(
                source: imageUrl,
                fit: BoxFit.cover,
                loading: _fallback(scheme),
                error: _fallback(scheme),
              ),
      ),
    );
  }

  Widget _fallback(ColorScheme scheme) {
    final trimmed = name.trim();
    return Container(
      color: scheme.primary.withValues(alpha: 0.16),
      alignment: Alignment.center,
      child: Text(
        trimmed.isEmpty ? '?' : trimmed.substring(0, 1),
        style: TextStyle(
          fontFamily: 'ResourceHanCN',
          fontWeight: FontWeight.w600,
          color: scheme.primary,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class MoChatDetailPage extends StatefulWidget {
  const MoChatDetailPage({
    super.key,
    required this.chatId,
    required this.title,
    required this.avatarUrl,
    this.studentId = 0,
    this.familyName = '',
    this.givenName = '',
    this.familyNames = const <String, String>{},
    this.givenNames = const <String, String>{},
    this.fullNames = const <String, String>{},
  });

  final String chatId;
  final String title;
  final String familyName;
  final String givenName;
  final String avatarUrl;
  final int studentId;
  final Map<String, String> familyNames;
  final Map<String, String> givenNames;
  final Map<String, String> fullNames;

  @override
  State<MoChatDetailPage> createState() => _MoChatDetailPageState();
}

class _MoChatDetailPageState extends State<MoChatDetailPage> {
  late final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _chatCaptureKey = GlobalKey();
  bool _aiTyping = false;
  bool _sendingAttachment = false;
  bool _sendAsStudent = false;
  late String _studentName = widget.title;
  late String _studentFamilyName = widget.familyName;
  late String _studentGivenName = widget.givenName;
  late Map<String, String> _studentFamilyNames = widget.familyNames;
  late Map<String, String> _studentGivenNames = widget.givenNames;
  late Map<String, String> _studentFullNames = widget.fullNames;
  late String _studentAvatar = widget.avatarUrl;
  late int _studentId = widget.studentId;

  String get _studentDisplayName => studentDisplayName(
    fullName: _studentName,
    familyName: _studentFamilyName,
    givenName: _studentGivenName,
    familyNames: _studentFamilyNames,
    givenNames: _studentGivenNames,
    fullNames: _studentFullNames,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_showCustomGreetingIfNeeded());
    });
  }

  void _showNotice(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> _sendImage(
    String imageSource, {
    bool isTeacher = true,
    String kind = 'image',
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (_sendingAttachment || imageSource.trim().isEmpty) return;
    setState(() => _sendingAttachment = true);
    try {
      await NoteStore.addMessage(
        chatId: widget.chatId,
        text: '',
        isTeacher: isTeacher,
        imageUrl: imageSource,
        kind: kind,
      );
      if (!mounted) return;
      setState(() {});
      _scrollToBottom();
    } catch (error) {
      if (mounted) _showNotice(l10n.image_send_failed(error.toString()));
    } finally {
      if (mounted) setState(() => _sendingAttachment = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final l10n = AppLocalizations.of(context)!;
    final path = await PlatformMediaService.pickImageFromGallery();
    if (!mounted) return;
    if (path == null || path.isEmpty) {
      _showNotice(l10n.image_pick_failed);
      return;
    }
    await _sendImage(path, isTeacher: !_sendAsStudent);
  }

  Future<void> _switchStudent() async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute<Object>(builder: (_) => const StudentPickerPage()),
    );
    if (!mounted || result == null) return;

    String? name;
    String? familyName;
    String? givenName;
    String? avatar;
    var familyNames = const <String, String>{};
    var givenNames = const <String, String>{};
    var fullNames = const <String, String>{};
    int id = 0;
    if (result is BuiltInStudent) {
      name = result.name;
      familyName = result.familyName;
      givenName = result.givenName;
      familyNames = result.familyNames;
      givenNames = result.givenNames;
      fullNames = result.fullNames;
      avatar = result.avatarUrl;
      id = result.id;
    } else if (result is CustomStudent) {
      name = result.name;
      familyName = result.familyName;
      givenName = result.givenName;
      avatar = result.avatarUrl;
    }
    if (name == null || name.isEmpty) return;

    await NoteStore.updateChatStudent(
      widget.chatId,
      name: name,
      familyName: familyName ?? '',
      givenName: givenName ?? '',
      avatarUrl: avatar ?? '',
      studentId: id,
      familyNames: familyNames,
      givenNames: givenNames,
      fullNames: fullNames,
    );
    if (!mounted) return;
    setState(() {
      _studentName = name!;
      _studentFamilyName = familyName ?? '';
      _studentGivenName = givenName ?? '';
      _studentFamilyNames = familyNames;
      _studentGivenNames = givenNames;
      _studentFullNames = fullNames;
      _studentAvatar = avatar ?? '';
      _studentId = id;
    });
  }

  Future<void> _openEmojiPicker({MoMessage? replaceMessage}) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final screen = MediaQuery.of(dialogContext).size;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: DeviceInfo.pt(20),
            vertical: DeviceInfo.pt(24),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          child: SizedBox(
            width: screen.width * 0.9,
            height: screen.height * 0.72,
            child: FutureBuilder<List<String>>(
              future: KivoGalleryService.initialPortraitVariants(
                studentName: _studentName,
                studentId: _studentId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final images = snapshot.data ?? const <String>[];
                final l10n = AppLocalizations.of(context)!;
                if (snapshot.hasError || images.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.face_retouching_natural, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            snapshot.hasError
                                ? l10n.gallery_load_failed
                                : l10n.gallery_not_found,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Text(
                        l10n.portrait_variants,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              Navigator.pop(dialogContext);
                              if (replaceMessage != null) {
                                await NoteStore.updateMessage(
                                  chatId: widget.chatId,
                                  messageId: replaceMessage.id,
                                  imageUrl: images[index],
                                  kind: 'student_expression',
                                );
                                if (mounted) setState(() {});
                              } else {
                                await _sendImage(
                                  images[index],
                                  isTeacher: false,
                                  kind: 'student_expression',
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const ColoredBox(
                                      color: Color(0x11000000),
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _takeScreenshot() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final boundary =
          _chatCaptureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        _showNotice(l10n.screenshot_failed);
        return;
      }
      final image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) {
        _showNotice(l10n.screenshot_failed);
        return;
      }
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/neonote_chat_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      await _sendImage(file.path, isTeacher: !_sendAsStudent);
    } catch (error) {
      if (mounted) _showNotice('${l10n.screenshot_failed}: $error');
    }
  }

  Future<void> _showMessageMenu(
    MoMessage message,
    Offset globalPosition,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final overlaySize = overlay?.size ?? MediaQuery.of(context).size;
    final left = globalPosition.dx.clamp(8.0, overlaySize.width - 8).toDouble();
    final top = globalPosition.dy.clamp(8.0, overlaySize.height - 8).toDouble();
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        left,
        top,
        overlaySize.width - left,
        overlaySize.height - top,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).colorScheme.surfaceContainer,
      items: [
        PopupMenuItem<String>(
          value: 'reorder',
          child: Row(
            children: [
              const Icon(Icons.swap_vert),
              const SizedBox(width: 12),
              Text(l10n.message_reorder),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined),
              const SizedBox(width: 12),
              Text(l10n.message_edit),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'transform',
          child: Row(
            children: [
              const Icon(Icons.transform),
              const SizedBox(width: 12),
              Text(l10n.message_transform),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline),
              const SizedBox(width: 12),
              Text(l10n.delete),
            ],
          ),
        ),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'reorder':
        await _showReorderMessages();
      case 'edit':
        await _changeMessage(message);
      case 'transform':
        _showNotice(l10n.transform_developing);
      case 'delete':
        await NoteStore.deleteMessage(
          chatId: widget.chatId,
          messageId: message.id,
        );
        if (mounted) setState(() {});
    }
  }

  Future<void> _changeMessage(MoMessage message) async {
    final l10n = AppLocalizations.of(context)!;
    if (message.hasImage) {
      if (message.isStudentExpression) {
        await _openEmojiPicker(replaceMessage: message);
        return;
      }
      final path = await PlatformMediaService.pickImageFromGallery();
      if (!mounted || path == null || path.isEmpty) return;
      await NoteStore.updateMessage(
        chatId: widget.chatId,
        messageId: message.id,
        imageUrl: path,
        kind: 'image',
      );
      if (mounted) setState(() {});
      return;
    }

    final controller = TextEditingController(text: message.text);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l10n.edit_message),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 1,
          maxLines: 6,
          decoration: InputDecoration(hintText: l10n.enter_new_message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || result == null) return;
    final next = result.trim();
    if (next.isEmpty) return;
    await NoteStore.updateMessage(
      chatId: widget.chatId,
      messageId: message.id,
      text: next,
      kind: 'text',
    );
    if (mounted) setState(() {});
  }

  Future<void> _showReorderMessages() async {
    final l10n = AppLocalizations.of(context)!;
    final messages = NoteStore.messages(widget.chatId);
    if (messages.length < 2) {
      _showNotice(l10n.not_enough_messages);
      return;
    }
    await showAdaptiveSurface<void>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.68,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                      child: Text(
                        l10n.drag_to_reorder,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: messages.length,
                        onReorder: (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = messages.removeAt(oldIndex);
                          messages.insert(newIndex, item);
                          setSheetState(() {});
                          await NoteStore.replaceMessages(
                            widget.chatId,
                            messages,
                          );
                          if (mounted) setState(() {});
                        },
                        itemBuilder: (context, index) {
                          final item = messages[index];
                          return ListTile(
                            key: ValueKey<String>(item.id),
                            leading: Icon(
                              item.hasImage
                                  ? Icons.image_outlined
                                  : Icons.chat_bubble_outline,
                            ),
                            title: Text(
                              item.text.trim().isEmpty
                                  ? l10n.ai_image_placeholder
                                  : item.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.drag_handle),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCustomGreetingIfNeeded() async {
    if (NoteStore.messages(widget.chatId).isNotEmpty) return;
    final greeting = NoteStore.getString('mochar_custom_greeting', '').trim();
    if (greeting.isEmpty) return;
    final box = Hive.box(themeBox);
    final shownKey = 'mochar_greeting_shown_${widget.chatId}';
    if (box.get(shownKey, defaultValue: false) == true) return;
    await box.put(shownKey, true);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.campaign_outlined),
        title: Text(
          l10n.custom_greeting,
          style: const TextStyle(fontFamily: 'ResourceHanCN'),
        ),
        content: Text(
          greeting,
          style: const TextStyle(fontFamily: 'ResourceHanCN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await NoteStore.addMessage(
      chatId: widget.chatId,
      text: text,
      isTeacher: !_sendAsStudent,
    );
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
    // A student message is the student's own turn; only teacher messages ask
    // DeepSeek to answer in the student's character.
    if (_sendAsStudent) return;
    final config = DeepseekConfig.load();
    if (config.isActive && !_aiTyping) {
      await _requestAiReply(config);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _requestAiReply(DeepseekConfig config) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _aiTyping = true);
    try {
      final history = NoteStore.messages(widget.chatId);
      final reply = await DeepseekService.complete(
        config: config,
        messages: [
          DeepseekMessage(
            role: 'system',
            content: _buildPersona(config.systemPrompt),
          ),
          for (final message in history)
            if (!message.hasImage && message.text.trim().isNotEmpty)
              DeepseekMessage(
                role: message.isTeacher ? 'user' : 'assistant',
                content: message.text,
              ),
        ],
      );
      await NoteStore.addMessage(
        chatId: widget.chatId,
        text: reply,
        isTeacher: false,
      );
      if (!mounted) return;
      setState(() {});
      _scrollToBottom();
    } on DeepseekException catch (error) {
      if (!mounted) return;
      _showAiError(l10n.ai_error, error.message);
    } catch (error) {
      if (!mounted) return;
      _showAiError(l10n.ai_error, error.toString());
    } finally {
      if (mounted) setState(() => _aiTyping = false);
    }
  }

  String _buildPersona(String basePrompt) {
    final parts = <String>[
      if (basePrompt.trim().isNotEmpty) basePrompt.trim(),
      'You are role-playing as the student $_studentName in a chat with a teacher. '
          'Stay in character, reply naturally and concisely, and use the same language as the teacher.',
    ];
    return parts.join('\n\n');
  }

  void _showAiError(String label, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label: $message'),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Widget _buildTypingIndicator(ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: DeviceInfo.pt(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _switchStudent,
            child: _MoAvatar(
              name: _studentDisplayName,
              imageUrl: _studentAvatar,
              size: DeviceInfo.pt(48),
            ),
          ),
          SizedBox(width: DeviceInfo.pt(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _studentDisplayName,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: DeviceInfo.pt(16),
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: DeviceInfo.pt(4)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DeviceInfo.pt(14),
                    vertical: DeviceInfo.pt(10),
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      NoteStore.getInt('mo_dialogColorNormal', 0xFF4C5B70),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(
                            NoteStore.getInt('mo_textColorNormal', 0xFFFFFFFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.ai_typing,
                        style: TextStyle(
                          fontFamily: 'ResourceHanCN',
                          fontSize: DeviceInfo.pt(13),
                          color: Color(
                            NoteStore.getInt('mo_textColorNormal', 0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final messages = NoteStore.messages(widget.chatId);
    final studentBubbleColor = Color(
      NoteStore.getInt('mo_dialogColorNormal', 0xFF4C5B70),
    );
    final studentTextColor = Color(
      NoteStore.getInt('mo_textColorNormal', 0xFFFFFFFF),
    );
    final teacherBubbleColor = Color(
      NoteStore.getInt('mo_dialogColorTeacher', 0xFF4A80CB),
    );
    final teacherTextColor = Color(
      NoteStore.getInt('mo_textColorTeacher', 0xFFFFFFFF),
    );
    final radius = NoteStore.getDouble('mo_cornerRadius', 8);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _switchStudent,
          child: Row(
            children: [
              _MoAvatar(
                name: _studentDisplayName,
                imageUrl: _studentAvatar,
                size: DeviceInfo.pt(32),
              ),
              SizedBox(width: DeviceInfo.pt(12)),
              Expanded(
                child: Text(
                  _studentDisplayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: DeviceInfo.pt(18),
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _chatCaptureKey,
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        l10n.no_messages,
                        style: TextStyle(
                          fontFamily: 'ResourceHanCN',
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(DeviceInfo.pt(16)),
                      itemCount: messages.length + (_aiTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= messages.length) {
                          return _buildTypingIndicator(scheme);
                        }
                        final message = messages[index];
                        final isTeacher = message.isTeacher;
                        final bubbleColor = isTeacher
                            ? teacherBubbleColor
                            : studentBubbleColor;
                        final bubbleText = isTeacher
                            ? teacherTextColor
                            : studentTextColor;
                        final avatarSize = DeviceInfo.pt(48);
                        final emojiSize = NoteStore.getInt(
                          'mo_emojiSize',
                          130,
                        ).toDouble();
                        final studentAvatarWidget = GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _switchStudent,
                          child: Tooltip(
                            message: l10n.switch_student,
                            child: _MoAvatar(
                              name: _studentDisplayName,
                              imageUrl: _studentAvatar,
                              size: avatarSize,
                            ),
                          ),
                        );
                        final content = GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onLongPressStart: (details) =>
                              _showMessageMenu(message, details.globalPosition),
                          child: message.hasImage
                              ? message.isStudentExpression
                                    ? SizedBox(
                                        width: emojiSize,
                                        height: emojiSize,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            radius < 8 ? 8 : radius,
                                          ),
                                          child: SourceImageView(
                                            source: message.imageUrl,
                                            fit: BoxFit.contain,
                                            loading: const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(24),
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            error: const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(24),
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.58,
                                          maxHeight: DeviceInfo.pt(300),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            radius < 8 ? 8 : radius,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: SourceImageView(
                                          source: message.imageUrl,
                                          fit: BoxFit.contain,
                                          loading: const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(24),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                          error: const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(24),
                                              child: Icon(
                                                Icons.broken_image_outlined,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                              : Bubble(
                                  text: message.text,
                                  color: bubbleColor,
                                  textColor: bubbleText,
                                  cornerRadius: radius < 8 ? 8 : radius,
                                  showTail: true,
                                  tailLeft: !isTeacher,
                                ),
                        );
                        final messageColumn = Column(
                          crossAxisAlignment: isTeacher
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isTeacher) ...[
                              Text(
                                _studentDisplayName,
                                style: TextStyle(
                                  fontFamily: 'ResourceHanCN',
                                  fontSize: DeviceInfo.pt(16),
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                              SizedBox(height: DeviceInfo.pt(4)),
                            ],
                            content,
                          ],
                        );
                        return Padding(
                          padding: EdgeInsets.only(bottom: DeviceInfo.pt(10)),
                          child: Row(
                            mainAxisAlignment: isTeacher
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: isTeacher
                                ? [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: messageColumn,
                                      ),
                                    ),
                                  ]
                                : [
                                    studentAvatarWidget,
                                    SizedBox(width: DeviceInfo.pt(8)),
                                    Expanded(child: messageColumn),
                                  ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              DeviceInfo.pt(8),
              DeviceInfo.pt(2),
              DeviceInfo.pt(8),
              0,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.emoji,
                  onPressed: _openEmojiPicker,
                  icon: const Icon(Icons.emoji_emotions_outlined),
                ),
                IconButton(
                  tooltip: l10n.image,
                  onPressed: _sendingAttachment ? null : _pickImageFromGallery,
                  icon: const Icon(Icons.image_outlined),
                ),
                IconButton(
                  tooltip: l10n.student,
                  onPressed: () {
                    setState(() => _sendAsStudent = !_sendAsStudent);
                    _showNotice(
                      _sendAsStudent
                          ? l10n.current_identity_student
                          : l10n.current_identity_teacher,
                    );
                  },
                  icon: Icon(
                    _sendAsStudent ? Icons.school : Icons.school_outlined,
                    color: _sendAsStudent
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                IconButton(
                  tooltip: l10n.switch_student,
                  onPressed: _switchStudent,
                  icon: const Icon(Icons.switch_account_outlined),
                ),
                IconButton(
                  tooltip: l10n.screenshot,
                  onPressed: _sendingAttachment ? null : _takeScreenshot,
                  icon: const Icon(Icons.screenshot_monitor),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DeviceInfo.pt(12),
                DeviceInfo.pt(6),
                DeviceInfo.pt(12),
                DeviceInfo.pt(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: DeviceInfo.pt(6),
                        bottom: 4,
                      ),
                      child: Text(
                        _sendAsStudent
                            ? l10n.send_as_student
                            : l10n.send_as_teacher,
                        style: TextStyle(
                          fontFamily: 'ResourceHanCN',
                          fontSize: DeviceInfo.pt(11),
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          cursorColor: scheme.primary,
                          style: TextStyle(
                            fontFamily: 'ResourceHanCN',
                            color: scheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.message_hint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: DeviceInfo.pt(16),
                              vertical: DeviceInfo.pt(12),
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      SizedBox(width: DeviceInfo.pt(8)),
                      IconButton(
                        onPressed: _send,
                        tooltip: l10n.send,
                        icon: Icon(Icons.send, color: scheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
