import 'package:flutter/material.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/store/note_store.dart';
import 'package:neonote/ui/app_layout.dart';
import 'package:neonote/widgets/accessible_icon_button.dart';
import 'package:neonote/widgets/empty_state.dart';

class ArchivedNotesPage extends StatelessWidget {
  const ArchivedNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.note_archive)),
      body: ContentPane(
        maxWidth: AppBreakpoints.wideContentMax,
        padding: EdgeInsets.zero,
        child: ValueListenableBuilder<int>(
          valueListenable: NoteStore.notesRevision,
          builder: (context, _, _) {
            final notes = NoteStore.archivedComponents();
            if (notes.isEmpty) {
              return EmptyState(
                icon: Icons.inventory_2_outlined,
                title: l10n.no_archived_notes,
                message: l10n.no_text_content,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.sticky_note_2_outlined),
                    title: Text(
                      note.title.trim().isEmpty ? note.type.name : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      note.text.trim().isEmpty
                          ? l10n.no_text_content_short
                          : note.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AccessibleIconButton(
                          tooltip: l10n.restore,
                          icon: const Icon(Icons.unarchive_outlined),
                          onPressed: () =>
                              NoteStore.setArchived(note.id, false),
                        ),
                        AccessibleIconButton(
                          tooltip: l10n.delete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => NoteStore.removeComponent(note.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ArchivedChatsPage extends StatelessWidget {
  const ArchivedChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.momotalk_archive)),
      body: ContentPane(
        maxWidth: AppBreakpoints.wideContentMax,
        padding: EdgeInsets.zero,
        child: ValueListenableBuilder<int>(
          valueListenable: NoteStore.chatsRevision,
          builder: (context, _, _) {
            final chats = NoteStore.archivedChats();
            if (chats.isEmpty) {
              return EmptyState(
                icon: Icons.forum_outlined,
                title: l10n.no_archived_chats,
                message: l10n.no_messages,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(chat.name),
                    subtitle: Text(
                      chat.lastMessage.isEmpty
                          ? l10n.no_messages
                          : chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AccessibleIconButton(
                          tooltip: l10n.restore,
                          icon: const Icon(Icons.unarchive_outlined),
                          onPressed: () =>
                              NoteStore.setChatArchived(chat.id, false),
                        ),
                        AccessibleIconButton(
                          tooltip: l10n.delete,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => NoteStore.deleteChat(chat.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
