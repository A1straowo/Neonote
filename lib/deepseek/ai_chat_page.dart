import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neonote/deepseek/ai_markdown.dart';
import 'package:neonote/deepseek/ai_message_actions.dart';
import 'package:neonote/deepseek/deepseek_settings_page.dart';
import 'package:neonote/deepseek/message_action_sheet.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show DeviceInfo;
import 'package:neonote/services/deepseek_service.dart';
import 'package:neonote/services/platform_media.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/ui/app_layout.dart';
import 'package:neonote/widgets/deepseek_icon.dart';
import 'package:neonote/widgets/image_source_view.dart';

/// A reusable DeepSeek chat screen.
///
/// Used by notes (with [onInsertReply] so answers can become note components)
/// and by MomoTalk as a general assistant.
class AiChatPage extends StatefulWidget {
  const AiChatPage({
    super.key,
    this.title,
    this.welcome,
    this.systemPrompt,
    this.onInsertReply,
  });

  final String? title;
  final String? welcome;
  final String? systemPrompt;
  final Future<void> Function(String text)? onInsertReply;

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiAttachment {
  const _AiAttachment({required this.path, required this.isImage});

  final String path;
  final bool isImage;
}

class _AiPopupChoice<T> {
  const _AiPopupChoice({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class _AiChatPageState extends State<AiChatPage> with WidgetsBindingObserver {
  static const List<String> _models = <String>[
    'deepseek-chat',
    'deepseek-reasoner',
  ];
  static const List<String> _levels = <String>['low', 'medium', 'high'];

  final List<DeepseekMessage> _messages = <DeepseekMessage>[];
  final List<_AiAttachment> _attachments = <_AiAttachment>[];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _sending = false;
  bool _recording = false;
  bool _dirtyConversation = false;
  String? _conversationId;
  int _conversationCreatedAt = DateTime.now().millisecondsSinceEpoch;
  late String _selectedModel;
  late String _reasoningLevel;
  late String _mode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final config = DeepseekConfig.load();
    _selectedModel = config.model;
    _reasoningLevel = config.reasoningLevel;
    _mode = config.mode == 'minimal' ? 'minimal' : 'standard';
    _loadLatestConversation();
  }

  void _loadLatestConversation() {
    final conversations = NoteStore.aiConversations();
    if (conversations.isEmpty) return;
    _applyConversation(conversations.first, notify: false);
  }

  void _applyConversation(AiConversation conversation, {bool notify = true}) {
    void apply() {
      _messages
        ..clear()
        ..addAll(
          conversation.messages.map(
            (message) => DeepseekMessage(
              role: message.role,
              content: message.content,
              imagePaths: List<String>.from(message.imagePaths),
              audioPaths: List<String>.from(message.audioPaths),
            ),
          ),
        );
      _attachments.clear();
      _conversationId = conversation.id;
      _conversationCreatedAt = conversation.createdAt;
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
    _scheduleScrollToBottom(animate: false);
  }

  String get _conversationTitle {
    for (final message in _messages) {
      if (message.role != 'user') continue;
      final text = message.content.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (text.isEmpty) continue;
      return text.length > 28 ? '${text.substring(0, 28)}…' : text;
    }
    return AppLocalizations.of(context)!.ai_new_conversation_title;
  }

  Future<void> _persistConversation() async {
    if (_messages.isEmpty) return;
    final conversation = AiConversation(
      id: _conversationId,
      title: _conversationTitle,
      createdAt: _conversationCreatedAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      messages: [
        for (final message in _messages)
          AiConversationMessage(
            role: message.role,
            content: message.content,
            imagePaths: List<String>.from(message.imagePaths),
            audioPaths: List<String>.from(message.audioPaths),
          ),
      ],
    );
    _conversationId = conversation.id;
    await NoteStore.saveAiConversation(conversation);
    _dirtyConversation = false;
  }

  Future<void> _persistConversationSafely() async {
    try {
      await _persistConversation();
    } catch (error) {
      _dirtyConversation = true;
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _toast(l10n.ai_conversation_save_failed(error.toString()));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_dirtyConversation) {
        unawaited(_persistConversationSafely());
      }
    }
  }

  Future<void> _startNewConversation() async {
    final l10n = AppLocalizations.of(context)!;
    if (_sending) {
      _toast(l10n.ai_wait_reply);
      return;
    }
    await _persistConversationSafely();
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _attachments.clear();
      _conversationId = null;
      _conversationCreatedAt = DateTime.now().millisecondsSinceEpoch;
    });
    _controller.clear();
    _toast(l10n.ai_conversation_created);
  }

  Future<void> _showHistory() async {
    final l10n = AppLocalizations.of(context)!;
    if (_sending) {
      _toast(l10n.ai_wait_reply);
      return;
    }
    final selected = await showAdaptiveSurface<AiConversation>(
      context: context,
      builder: (_) => const _AiHistorySheet(),
    );
    if (!mounted || selected == null) return;
    _applyConversation(selected);
    _scrollToBottom();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_recording) {
      unawaited(PlatformMediaService.stopRecording());
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  void _scrollToBottom() => _scheduleScrollToBottom();

  void _scheduleScrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DeepseekSettingsPage()));
    if (!mounted) return;
    final config = DeepseekConfig.load();
    setState(() {
      _selectedModel = config.model;
      _reasoningLevel = config.reasoningLevel;
      _mode = config.mode == 'minimal' ? 'minimal' : 'standard';
    });
  }

  bool get _modelMayNotSupportVision =>
      _selectedModel == 'deepseek-chat' ||
      _selectedModel == 'deepseek-reasoner';

  String get _modeLabel {
    final l10n = AppLocalizations.of(context)!;
    return _mode == 'minimal' ? l10n.ai_mode_minimal : l10n.ai_mode_standard;
  }

  String get _reasoningLabel {
    final l10n = AppLocalizations.of(context)!;
    return switch (_reasoningLevel) {
      'low' => l10n.ai_reasoning_low,
      'high' => l10n.ai_reasoning_high,
      _ => l10n.ai_reasoning_medium,
    };
  }

  String get _modePrompt {
    if (_mode == 'minimal') {
      return 'You are a concise, flexible DeepSeek assistant. Prioritize the '
          'user request, including brief everyday conversation or requested '
          'role-play, and keep answers short. Your underlying identity is '
          'DeepSeek.';
    }
    return 'You are a flexible DeepSeek assistant inside a note-taking app. '
        'Help with drafting, organization, summaries, questions, planning, '
        'creative writing, coding when asked, everyday conversation, and '
        'requested role-play. You may adopt a temporary persona while keeping '
        'DeepSeek as your underlying identity.';
  }

  int get _maxTokens => switch (_reasoningLevel) {
    'low' => 600,
    'high' => 2400,
    _ => 1200,
  };

  double get _temperature => _mode == 'minimal' ? 0.3 : 0.7;

  Future<DeepseekConfig> _saveComposerOptions() async {
    final base = DeepseekConfig.load();
    final config = base.copyWith(
      model: _selectedModel,
      reasoningLevel: _reasoningLevel,
      mode: _mode,
    );
    await config.save();
    return config;
  }

  Future<void> _showImagePreview(String path) async {
    final l10n = AppLocalizations.of(context)!;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.close_image_preview,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, _) => SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SourceImageView(
                      source: path,
                      fit: BoxFit.contain,
                      loading: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      error: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                tooltip: l10n.close,
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final l10n = AppLocalizations.of(context)!;
    final path = fromCamera
        ? await PlatformMediaService.takePhoto()
        : await PlatformMediaService.pickImageFromGallery();
    if (!mounted) return;
    if (path == null || path.isEmpty) {
      _toast(l10n.image_pick_failed);
      return;
    }
    setState(() {
      _attachments.add(_AiAttachment(path: path, isImage: true));
    });
    _toast(
      _modelMayNotSupportVision
          ? l10n.ai_image_model_warning
          : l10n.ai_image_added,
    );
  }

  Future<void> _toggleRecording() async {
    final l10n = AppLocalizations.of(context)!;
    if (_recording) {
      final path = await PlatformMediaService.stopRecording();
      if (!mounted) return;
      setState(() => _recording = false);
      if (path != null && path.isNotEmpty) {
        setState(() {
          _attachments.add(_AiAttachment(path: path, isImage: false));
        });
      } else {
        _toast(l10n.record_failed);
      }
      return;
    }

    final started = await PlatformMediaService.startRecording();
    if (!mounted) return;
    if (started) {
      setState(() => _recording = true);
    } else {
      _toast(l10n.mic_permission_denied);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _attachments.isEmpty) || _sending) return;

    final l10n = AppLocalizations.of(context)!;
    final config = await _saveComposerOptions();
    if (!config.enabled) {
      _toast(l10n.deepseek_disabled);
      return;
    }
    if (!config.isConfigured) {
      _toast(l10n.deepseek_not_configured);
      return;
    }

    final imagePaths = _attachments
        .where((item) => item.isImage)
        .map((item) => item.path)
        .toList();
    final audioPaths = _attachments
        .where((item) => !item.isImage)
        .map((item) => item.path)
        .toList();
    final displayText = text.isNotEmpty
        ? text
        : imagePaths.isNotEmpty
        ? l10n.ai_image_placeholder
        : l10n.ai_voice_placeholder;

    _controller.clear();
    setState(() {
      _messages.add(
        DeepseekMessage(
          role: 'user',
          content: displayText,
          imagePaths: imagePaths,
          audioPaths: audioPaths,
        ),
      );
      _attachments.clear();
      _sending = true;
    });
    await _persistConversationSafely();
    if (!mounted) return;
    _scrollToBottom();
    await _requestAssistantReply(config, l10n);
  }

  Future<void> _requestAssistantReply(
    DeepseekConfig config,
    AppLocalizations l10n,
  ) async {
    try {
      final systemParts = <String>[
        if (config.systemPrompt.trim().isNotEmpty) config.systemPrompt.trim(),
        if (widget.systemPrompt != null &&
            widget.systemPrompt!.trim().isNotEmpty)
          widget.systemPrompt!.trim(),
        _modePrompt,
      ];
      final requestMessages = <DeepseekMessage>[
        if (systemParts.isNotEmpty)
          DeepseekMessage(role: 'system', content: systemParts.join('\n\n')),
        for (final message in _messages)
          DeepseekMessage(
            role: message.role,
            content: [
              if (message.content.trim().isNotEmpty) message.content.trim(),
              if (message.audioPaths.isNotEmpty) l10n.ai_voice_attached,
            ].join('\n'),
            imagePaths: message.role == 'user'
                ? List<String>.from(message.imagePaths)
                : const <String>[],
            audioPaths: List<String>.from(message.audioPaths),
          ),
      ];
      final reply = await DeepseekService.complete(
        config: config,
        messages: requestMessages,
        temperature: _temperature,
        maxTokens: _maxTokens,
      );
      if (!mounted) return;
      setState(
        () => _messages.add(DeepseekMessage(role: 'assistant', content: reply)),
      );
      await _persistConversationSafely();
      if (!mounted) return;
      _scrollToBottom();
    } on DeepseekException catch (error) {
      if (!mounted) return;
      _toast('${l10n.ai_error}: ${error.message}');
    } catch (error) {
      if (!mounted) return;
      _toast('${l10n.ai_error}: $error');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _regenerateLastReply() async {
    if (_sending) return;
    final lastAssistant = _messages.lastIndexWhere(
      (message) => message.role == 'assistant',
    );
    if (lastAssistant < 0) return;
    await _regenerateAt(lastAssistant);
  }

  Future<void> _regenerateAt(int index) async {
    if (_sending) return;
    if (index < 0 || index >= _messages.length) return;
    if (_messages[index].role != 'assistant') return;

    final userIndex = index > 0
        ? _messages.lastIndexWhere(
            (message) => message.role == 'user',
            index - 1,
          )
        : -1;
    if (userIndex < 0) return;

    final l10n = AppLocalizations.of(context)!;
    final config = await _saveComposerOptions();
    if (!config.enabled) {
      _toast(l10n.deepseek_disabled);
      return;
    }
    if (!config.isConfigured) {
      _toast(l10n.deepseek_not_configured);
      return;
    }

    setState(() {
      // The selected reply and everything after it are invalid once the
      // context changes, so remove them before requesting a fresh reply.
      _messages.removeRange(index, _messages.length);
      _sending = true;
    });
    await _persistConversationSafely();
    if (!mounted) return;
    _scheduleScrollToBottom(animate: false);
    await _requestAssistantReply(config, l10n);
  }

  AiMessageActionLabels _messageActionLabels(AppLocalizations l10n) {
    return AiMessageActionLabels(
      title: l10n.message_actions,
      copy: l10n.copy,
      selectText: l10n.select_text,
      edit: l10n.message_edit,
      regenerate: l10n.regenerate_reply,
      delete: l10n.delete,
      close: l10n.close,
      cancel: l10n.cancel,
      save: l10n.save,
      deleteTitle: l10n.delete_message_confirm,
      deleteBody: l10n.delete_message_body,
      regenerateTitle: l10n.regenerate_confirm,
      removeFollowingBody: l10n.remove_following_messages,
      copyFailed: l10n.copy_reply_failed,
      editHint: l10n.edit_message_hint,
    );
  }

  Future<void> _openMessageActions(int index) async {
    if (index < 0 || index >= _messages.length) return;
    final l10n = AppLocalizations.of(context)!;
    if (_sending) {
      _toast(l10n.ai_wait_reply);
      return;
    }

    final message = _messages[index];
    final isAssistant = message.role == 'assistant';
    final hasFollowing = index < _messages.length - 1;
    final labels = _messageActionLabels(l10n);
    final action = await showAiMessageActionSheet(
      context,
      isAssistant: isAssistant,
      hasFollowingMessages: hasFollowing,
      labels: labels,
    );
    if (!mounted || action == null) return;

    switch (action) {
      case AiMessageAction.copy:
        await copyAiMessageText(
          context,
          message.content,
          copiedMessage: l10n.reply_copied,
          labels: labels,
        );
        return;
      case AiMessageAction.selectText:
        await showSelectableMessageDialog(
          context,
          text: message.content,
          labels: labels,
        );
        return;
      case AiMessageAction.edit:
        final edited = await showEditAiMessageDialog(
          context,
          initialText: message.content,
          labels: labels,
        );
        if (!mounted ||
            edited == null ||
            edited == message.content ||
            index >= _messages.length) {
          return;
        }
        final original = _messages[index];
        setState(() {
          _messages[index] = DeepseekMessage(
            role: original.role,
            content: edited,
            imagePaths: List<String>.from(original.imagePaths),
            audioPaths: List<String>.from(original.audioPaths),
          );
        });
        await _persistConversationSafely();
        return;
      case AiMessageAction.regenerate:
        if (!isAssistant) return;
        final confirmed = await confirmRegenerateAiMessage(
          context,
          hasFollowingMessages: hasFollowing,
          labels: labels,
        );
        if (!mounted || !confirmed) return;
        await _regenerateAt(index);
        return;
      case AiMessageAction.delete:
        final confirmed = await confirmDeleteAiMessage(context, labels: labels);
        if (!mounted || !confirmed || index >= _messages.length) return;
        setState(() => _messages.removeAt(index));
        await _persistConversationSafely();
        return;
    }
  }

  Future<void> _insertIntoNotes(String text) async {
    final callback = widget.onInsertReply;
    if (callback == null) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      await callback(text);
      if (!mounted) return;
      _toast(l10n.ai_inserted_to_note);
    } catch (error) {
      if (!mounted) return;
      _toast('${l10n.ai_error}: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final isLandscape = mediaSize.width > mediaSize.height;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        centerTitle: true,
        toolbarHeight: isLandscape ? 48 : null,
        leading: IconButton(
          tooltip: l10n.close,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'DeepSeek',
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: scheme.onSurface,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.ai_new_conversation,
            visualDensity: isLandscape ? VisualDensity.compact : null,
            onPressed: _startNewConversation,
            icon: Icon(Icons.add_comment_outlined, color: scheme.onSurface),
          ),
          IconButton(
            tooltip: l10n.ai_history,
            visualDensity: isLandscape ? VisualDensity.compact : null,
            onPressed: _showHistory,
            icon: Icon(Icons.history, color: scheme.onSurface),
          ),
          IconButton(
            tooltip: l10n.deepseek_harness,
            visualDensity: isLandscape ? VisualDensity.compact : null,
            onPressed: _openSettings,
            icon: Icon(Icons.settings_outlined, color: scheme.onSurface),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty && !_sending
                    ? _buildWelcome(scheme, l10n)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: DeviceInfo.pt(isLandscape ? 24 : 16),
                          vertical: DeviceInfo.pt(isLandscape ? 8 : 16),
                        ),
                        itemCount: _messages.length + (_sending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _messages.length) {
                            return _buildTyping(scheme, l10n);
                          }
                          return _buildMessage(
                            context,
                            index,
                            _messages[index],
                            l10n,
                            scheme,
                          );
                        },
                      ),
              ),
              _buildComposer(scheme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(ColorScheme scheme, AppLocalizations l10n) {
    final models = <String>{_selectedModel, ..._models}.toList();
    final isLandscape =
        MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;

    final actionButtons = <Widget>[
      IconButton(
        tooltip: l10n.take_photo,
        onPressed: () => _pickImage(fromCamera: true),
        icon: const Icon(Icons.camera_alt_outlined),
      ),
      IconButton(
        tooltip: l10n.gallery,
        onPressed: () => _pickImage(fromCamera: false),
        icon: const Icon(Icons.photo_library_outlined),
      ),
      IconButton(
        tooltip: _recording ? l10n.stop_recording : l10n.voice,
        onPressed: _toggleRecording,
        icon: Icon(
          _recording ? Icons.stop_circle : Icons.mic_none,
          color: _recording ? Colors.red : null,
        ),
      ),
    ];

    final chips = <Widget>[
      _buildPopupChip(
        context,
        icon: Icons.memory,
        label: _selectedModel,
        options: [
          for (final model in models)
            _AiPopupChoice<String>(
              value: model,
              label: model,
              icon: Icons.memory,
            ),
        ],
        onSelected: (value) => setState(() => _selectedModel = value),
      ),
      SizedBox(width: DeviceInfo.pt(6)),
      _buildPopupChip(
        context,
        icon: Icons.psychology_outlined,
        label: _reasoningLabel,
        options: [
          for (final level in _levels)
            _AiPopupChoice<String>(
              value: level,
              label: switch (level) {
                'low' => l10n.ai_reasoning_low,
                'high' => l10n.ai_reasoning_high,
                _ => l10n.ai_reasoning_medium,
              },
              icon: Icons.psychology_outlined,
            ),
        ],
        onSelected: (value) => setState(() => _reasoningLevel = value),
      ),
      SizedBox(width: DeviceInfo.pt(6)),
      _buildPopupChip(
        context,
        icon: Icons.tune,
        label: _modeLabel,
        options: [
          _AiPopupChoice<String>(
            value: 'standard',
            label: l10n.ai_mode_standard,
            icon: Icons.tune,
          ),
          _AiPopupChoice<String>(
            value: 'minimal',
            label: l10n.ai_mode_minimal,
            icon: Icons.tune,
          ),
        ],
        onSelected: (value) => setState(() => _mode = value),
      ),
    ];

    final inputRow = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: isLandscape ? 3 : 5,
            cursorColor: scheme.primary,
            style: TextStyle(
              fontFamily: 'ResourceHanCN',
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: l10n.ai_input_hint,
              filled: true,
              fillColor: scheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: DeviceInfo.pt(16),
                vertical: DeviceInfo.pt(10),
              ),
            ),
            onSubmitted: (_) => _send(),
          ),
        ),
        SizedBox(width: DeviceInfo.pt(8)),
        IconButton(
          onPressed: _sending ? null : _send,
          tooltip: l10n.send,
          icon: Icon(Icons.send, color: scheme.primary),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            DeviceInfo.pt(12),
            DeviceInfo.pt(isLandscape ? 5 : 8),
            DeviceInfo.pt(12),
            DeviceInfo.pt(isLandscape ? 5 : 10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_attachments.any((attachment) => attachment.isImage) &&
                  _modelMayNotSupportVision)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: DeviceInfo.pt(6)),
                  padding: EdgeInsets.symmetric(
                    horizontal: DeviceInfo.pt(10),
                    vertical: DeviceInfo.pt(6),
                  ),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: scheme.onErrorContainer,
                      ),
                      SizedBox(width: DeviceInfo.pt(6)),
                      Expanded(
                        child: Text(
                          l10n.ai_image_model_warning,
                          style: TextStyle(
                            fontFamily: 'ResourceHanCN',
                            fontSize: DeviceInfo.pt(11),
                            color: scheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_attachments.isNotEmpty) _buildAttachmentBar(scheme),
              if (isLandscape)
                SizedBox(
                  height: DeviceInfo.pt(42),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...actionButtons,
                        SizedBox(width: DeviceInfo.pt(6)),
                        ...chips,
                      ],
                    ),
                  ),
                )
              else ...[
                Row(children: actionButtons),
                SizedBox(
                  height: DeviceInfo.pt(38),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: chips),
                  ),
                ),
                SizedBox(height: DeviceInfo.pt(4)),
              ],
              inputRow,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPopupAbove<T>(
    BuildContext anchorContext,
    List<_AiPopupChoice<T>> options,
    ValueChanged<T> onSelected,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
    final anchor = anchorContext.findRenderObject() as RenderBox?;
    if (overlay == null || anchor == null) return;

    final anchorOffset = anchor.localToGlobal(Offset.zero, ancestor: overlay);
    final overlaySize = overlay.size;
    final scheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(
      fontFamily: 'ResourceHanCN',
      fontSize: 14,
      color: scheme.onSurface,
    );
    var widestLabel = 0.0;
    for (final option in options) {
      final painter = TextPainter(
        text: TextSpan(text: option.label, style: textStyle),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: 220);
      final width = painter.width;
      if (width > widestLabel) widestLabel = width;
      painter.dispose();
    }
    final hasIcon = options.any((option) => option.icon != null);
    // Size the menu to its content instead of always reserving a wide row.
    final menuWidth = (widestLabel + (hasIcon ? 38 : 24) + 34)
        .clamp(132.0, 260.0)
        .toDouble();
    final menuHeight = options.length * 46.0 + 12;
    final left = anchorOffset.dx
        .clamp(8.0, overlaySize.width - menuWidth - 8)
        .toDouble();
    // The menu is deliberately placed above the chip (not below it).
    final top = (anchorOffset.dy - menuHeight - 8)
        .clamp(8.0, overlaySize.height - menuHeight - 8)
        .toDouble();

    final selected = await showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.close_menu,
      barrierColor: const Color(0x12000000),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, _, _) => Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            width: menuWidth,
            child: Material(
              color: scheme.surfaceContainer,
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in options)
                      InkWell(
                        onTap: () => Navigator.pop(dialogContext, option.value),
                        child: SizedBox(
                          height: 46,
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              if (option.icon != null) ...[
                                Icon(
                                  option.icon,
                                  size: 18,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              Expanded(
                                child: Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'ResourceHanCN',
                                    fontSize: 14,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.82, end: 1).animate(curved),
              alignment: Alignment.bottomLeft,
              child: child,
            ),
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    onSelected(selected);
  }

  Widget _buildPopupChip<T>(
    BuildContext context, {
    required IconData icon,
    required String label,
    required List<_AiPopupChoice<T>> options,
    required ValueChanged<T> onSelected,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Builder(
      builder: (chipContext) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPopupAbove<T>(chipContext, options, onSelected),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DeviceInfo.pt(10),
              vertical: DeviceInfo.pt(7),
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 12,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBar(ColorScheme scheme) {
    return Container(
      height: DeviceInfo.pt(72),
      margin: EdgeInsets.only(bottom: DeviceInfo.pt(6)),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final attachment = _attachments[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: attachment.isImage
                    ? GestureDetector(
                        onTap: () => _showImagePreview(attachment.path),
                        child: SizedBox(
                          width: DeviceInfo.pt(64),
                          height: DeviceInfo.pt(64),
                          child: SourceImageView(
                            source: attachment.path,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        width: DeviceInfo.pt(64),
                        height: DeviceInfo.pt(64),
                        color: scheme.onSurface.withValues(alpha: 0.08),
                        child: const Icon(Icons.graphic_eq, size: 30),
                      ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Semantics(
                  button: true,
                  label: AppLocalizations.of(context)!.delete,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!.delete,
                    child: InkWell(
                      onTap: () => setState(() => _attachments.removeAt(index)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcome(ColorScheme scheme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DeviceInfo.pt(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DeepseekIcon(
              size: DeviceInfo.pt(56),
              color: scheme.primary.withValues(alpha: 0.7),
            ),
            SizedBox(height: DeviceInfo.pt(16)),
            Text(
              'Powered by DeepSeek',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'ResourceHanCN',
                fontSize: DeviceInfo.pt(15),
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(
    BuildContext context,
    int index,
    DeepseekMessage message,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    final isUser = message.role == 'user';
    final isLastMessage =
        _messages.isNotEmpty && identical(_messages.last, message);
    final mediaSize = MediaQuery.sizeOf(context);
    final maxBubbleWidth = mediaSize.width > mediaSize.height
        ? (mediaSize.width * 0.56).clamp(280.0, 560.0).toDouble()
        : mediaSize.width * 0.78;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _openMessageActions(index),
      onSecondaryTap: () => _openMessageActions(index),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: maxBubbleWidth),
              padding: EdgeInsets.all(DeviceInfo.pt(12)),
              decoration: BoxDecoration(
                color: isUser
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.content.trim().isNotEmpty)
                    if (isUser)
                      SelectableText(
                        message.content,
                        style: TextStyle(
                          fontFamily: 'ResourceHanCN',
                          fontSize: DeviceInfo.pt(15),
                          color: scheme.onPrimary,
                        ),
                      )
                    else
                      AiMarkdownText(
                        message.content,
                        style: TextStyle(
                          fontFamily: 'ResourceHanCN',
                          fontSize: DeviceInfo.pt(15),
                          color: scheme.onSurface,
                        ),
                      ),
                  if (message.imagePaths.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final path in message.imagePaths)
                          GestureDetector(
                            onTap: () => _showImagePreview(path),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: SourceImageView(
                                  source: path,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (message.audioPaths.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.graphic_eq,
                          color: isUser ? scheme.onPrimary : scheme.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.ai_voice_count(message.audioPaths.length),
                          style: TextStyle(
                            color: isUser ? scheme.onPrimary : scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isUser)
            Align(
              alignment: Alignment.centerLeft,
              child: AiMessageActions(
                content: message.content,
                insertLabel: l10n.ai_insert_note,
                regenerateLabel: l10n.regenerate_reply,
                copyTooltip: l10n.copy_reply,
                copiedMessage: l10n.reply_copied,
                copyFailedMessage: l10n.copy_reply_failed,
                onInsert: widget.onInsertReply == null
                    ? null
                    : () => _insertIntoNotes(message.content),
                onRegenerate:
                    isLastMessage && message.role == 'assistant' && !_sending
                    ? _regenerateLastReply
                    : null,
              ),
            ),
          SizedBox(height: DeviceInfo.pt(8)),
        ],
      ),
    );
  }

  Widget _buildTyping(ColorScheme scheme, AppLocalizations l10n) {
    DeepseekMessage? lastUser;
    for (final message in _messages.reversed) {
      if (message.role == 'user') {
        lastUser = message;
        break;
      }
    }
    final typingLabel = lastUser != null && lastUser.imagePaths.isNotEmpty
        ? l10n.ai_recognizing_image
        : l10n.ai_thinking;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: DeviceInfo.pt(8)),
        padding: EdgeInsets.symmetric(
          horizontal: DeviceInfo.pt(14),
          vertical: DeviceInfo.pt(10),
        ),
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: 0.06),
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
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              typingLabel,
              style: TextStyle(
                fontFamily: 'ResourceHanCN',
                fontSize: DeviceInfo.pt(13),
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiHistorySheet extends StatefulWidget {
  const _AiHistorySheet();

  @override
  State<_AiHistorySheet> createState() => _AiHistorySheetState();
}

class _AiHistorySheetState extends State<_AiHistorySheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<AiConversation> _conversations = NoteStore.aiConversations();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _preview(AiConversation conversation) {
    final l10n = AppLocalizations.of(context)!;
    if (conversation.messages.isEmpty) return l10n.ai_empty_conversation;
    final last = conversation.messages.last;
    final text = last.content.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) {
      if (last.imagePaths.isNotEmpty) return l10n.ai_image_placeholder;
      if (last.audioPaths.isNotEmpty) return l10n.ai_voice_placeholder;
    }
    return text.length > 46 ? '${text.substring(0, 46)}…' : text;
  }

  String _dateLabel(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteConversation(AiConversation conversation) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(l10n.ai_delete_conversation),
        content: Text(conversation.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await NoteStore.deleteAiConversation(conversation.id);
    if (!mounted) return;
    setState(() => _conversations = NoteStore.aiConversations());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _conversations
        : _conversations.where((conversation) {
            if (conversation.title.toLowerCase().contains(query)) return true;
            return conversation.messages.any(
              (message) => message.content.toLowerCase().contains(query),
            );
          }).toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    l10n.ai_history,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.ai_search_history,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        _conversations.isEmpty
                            ? l10n.ai_no_history
                            : l10n.ai_no_history_match,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final conversation = filtered[index];
                        return ListTile(
                          onTap: () => Navigator.pop(context, conversation),
                          leading: CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            foregroundColor: scheme.onPrimaryContainer,
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            conversation.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _preview(conversation),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _dateLabel(conversation.updatedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.ai_delete_conversation,
                                onPressed: () =>
                                    _deleteConversation(conversation),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
