// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart';
import 'package:neonote/services/gesture_settings.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/ui/app_layout.dart';
import 'package:neonote/widgets/ball_actions.dart';
import 'package:neonote/widgets/exit_save_dialog.dart';
import 'package:neonote/widgets/floating_ball.dart';
import 'package:neonote/widgets/note_component_card.dart';
import 'package:neonote/workbench.dart';

class NoteEditorView extends StatefulWidget {
  const NoteEditorView({super.key});

  @override
  State<NoteEditorView> createState() => NoteEditorViewState();
}

class NoteEditorViewState extends State<NoteEditorView>
    with WidgetsBindingObserver {
  List<NoteComponent> _components = <NoteComponent>[];
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = <String, GlobalKey>{};
  Timer? _saveTimer;
  bool _dirty = false;

  bool get _autoSaveEnabled =>
      Hive.box(themeBox).get('autoSave', defaultValue: true) == true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _components = _loadActiveComponents();
    NoteStore.notesRevision.addListener(_reload);
    NoteStore.tagsRevision.addListener(_reload);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NoteStore.notesRevision.removeListener(_reload);
    NoteStore.tagsRevision.removeListener(_reload);
    _saveTimer?.cancel();
    _scrollController.dispose();
    if (_autoSaveEnabled) {
      _persist();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_autoSaveEnabled) {
        _persist();
      }
    }
  }

  List<NoteComponent> _loadActiveComponents() {
    final list = NoteStore.activeComponents();
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return 0;
    });
    return list;
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _components = _loadActiveComponents());
  }

  Future<void> _persist() async {
    final archived = NoteStore.archivedComponents();
    await NoteStore.saveComponents([..._components, ...archived]);
    _dirty = false;
  }

  Future<void> saveNow() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    await _persist();
  }

  void _scheduleSave() {
    _dirty = true;
    _saveTimer?.cancel();
    _saveTimer = null;

    if (!_autoSaveEnabled) return;

    _saveTimer = Timer(const Duration(milliseconds: 400), () async {
      _saveTimer = null;
      await _persist();
    });
  }

  Future<bool> prepareForExit() async {
    if (_autoSaveEnabled) {
      await saveNow();
      return true;
    }

    if (!_dirty) return true;

    final decision = await showExitSaveDialog(context);
    if (!mounted) return false;

    if (decision == ExitSaveDecision.save) {
      await saveNow();
    }
    return true;
  }

  void _openWorkbench(NoteComponent component) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkbenchPage(component: component)),
    );
  }

  /// Scrolls a note found by search into view. Keeping this on the editor state
  /// means the main page does not need to know how the preview list is built.
  Future<void> revealComponent(String componentId) async {
    final index = _components.indexWhere((item) => item.id == componentId);
    if (index < 0 || !mounted) return;
    final itemKey = _itemKeys.putIfAbsent(componentId, GlobalKey.new);
    if (itemKey.currentContext == null && _scrollController.hasClients) {
      // Lazy list items outside the viewport have no context yet. Move to an
      // estimated position first so the target card is built, then use
      // ensureVisible to align it precisely.
      final position = _scrollController.position;
      final fraction = _components.length <= 1
          ? 0.0
          : index / (_components.length - 1);
      await _scrollController.animateTo(
        (position.maxScrollExtent * fraction).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
      await WidgetsBinding.instance.endOfFrame;
    }
    final itemContext = itemKey.currentContext;
    if (itemContext == null || !itemContext.mounted || !mounted) {
      if (_components.length > index) _openWorkbench(_components[index]);
      return;
    }
    await Scrollable.ensureVisible(
      itemContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.12,
    );
  }

  Future<void> _remove(NoteComponent component) async {
    await NoteStore.removeComponent(component.id);
  }

  Future<void> _editTags(NoteComponent component) async {
    final result = await _pickTags(component.tagIds);
    if (result == null) return;
    await NoteStore.setTags(component.id, result);
  }

  Future<List<String>?> _pickTags(List<String> selectedIds) {
    final tags = NoteStore.tags();
    final selected = selectedIds.toSet();

    return showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              scrollable: true,
              title: Text(AppLocalizations.of(context)!.select_tags),
              content: tags.isEmpty
                  ? Text(AppLocalizations.of(context)!.create_tag_first)
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final tag in tags)
                            CheckboxListTile(
                              value: selected.contains(tag.id),
                              title: Text(tag.name),
                              onChanged: (value) {
                                setLocalState(() {
                                  if (value == true) {
                                    selected.add(tag.id);
                                  } else {
                                    selected.remove(tag.id);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, selected.toList()),
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _applyGesture(
    NoteComponent component,
    GestureAction action,
  ) async {
    switch (action) {
      case GestureAction.pin:
        await NoteStore.setPinned(component.id, !component.pinned);
        return;
      case GestureAction.archive:
        await NoteStore.setArchived(component.id, true);
        return;
      case GestureAction.mark:
        await NoteStore.setMarked(component.id, !component.marked);
        return;
      case GestureAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            scrollable: true,
            title: Text(AppLocalizations.of(context)!.component_delete),
            content: Text(
              AppLocalizations.of(context)!.delete_component_confirm,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await _remove(component);
        }
        return;
    }
  }

  Widget _gestureBackground(GestureAction action, Alignment alignment) {
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DeviceInfo.pt(18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            action.label(AppLocalizations.of(context)!),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildBody(context)),
        FloatingBallMenu(items: buildNoteBallItems(context)),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    // Keep the home canvas intentionally blank when there are no notes.
    // Content creation remains available from the floating action menu.
    if (_components.isEmpty) return const SizedBox.expand();

    final rightAction = GestureSettings.rightAction;
    final leftAction = GestureSettings.leftAction;
    final tagNames = <String, String>{
      for (final tag in NoteStore.tags()) tag.id: tag.name,
    };
    final maxCardWidth = AppBreakpoints.isExpanded(context)
        ? AppBreakpoints.wideContentMax
        : double.infinity;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        DeviceInfo.pt(20),
        DeviceInfo.pt(12),
        DeviceInfo.pt(20),
        DeviceInfo.pt(140),
      ),
      itemCount: _components.length,
      itemBuilder: (context, index) {
        final component = _components[index];
        final itemKey = _itemKeys.putIfAbsent(component.id, GlobalKey.new);
        final card = Dismissible(
          key: ValueKey('note_${component.id}'),
          direction: DismissDirection.horizontal,
          background: _gestureBackground(rightAction, Alignment.centerLeft),
          secondaryBackground: _gestureBackground(
            leftAction,
            Alignment.centerRight,
          ),
          confirmDismiss: (direction) async {
            final action = direction == DismissDirection.startToEnd
                ? rightAction
                : leftAction;
            await _applyGesture(component, action);
            return false;
          },
          child: KeyedSubtree(
            key: itemKey,
            child: NoteComponentCard(
              key: ValueKey<String>(component.id),
              preview: true,
              component: component,
              onChanged: _scheduleSave,
              onDelete: () => _remove(component),
              onOpen: () => _openWorkbench(component),
              onEditTags: () => _editTags(component),
              tagNames: tagNames,
            ),
          ),
        );
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCardWidth),
            child: card,
          ),
        );
      },
    );
  }
}
