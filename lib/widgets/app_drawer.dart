// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show DeviceInfo;
import 'package:neonote/momotalk/mohome.dart';
import 'package:neonote/search.dart';
import 'package:neonote/settings.dart' show MySettingPage;
import 'package:neonote/store/note_store.dart';
import 'package:neonote/widgets/accessible_icon_button.dart';
import 'package:neonote/widgets/archive_pages.dart';
import 'package:neonote/widgets/floating_ball.dart';

enum AppDrawerPage { note, momoTalk }

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.activePage});

  final AppDrawerPage activePage;

  static const double _iconSizeSmall = 20;
  static const double _fontSizeSub = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final isLandscape = mediaSize.width > mediaSize.height;

    return Drawer(
      width: isLandscape
          ? (mediaSize.width * 0.58).clamp(360.0, 480.0).toDouble()
          : null,
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isLandscape) {
              return _buildLandscapeDrawer(context, constraints, l10n, scheme);
            }
            final compact = constraints.maxHeight < 700;
            final horizontalPadding = constraints.maxWidth < 340 ? 16.0 : 24.0;
            final topGap = compact ? 8.0 : 20.0;
            final iconSize = DeviceInfo.pt(compact ? 20 : 24);
            final headerSize = compact ? 52.0 : 72.0;
            final headerHeight = compact ? 64.0 : 100.0;
            final gap = compact ? 4.0 : 10.0;
            final density = compact
                ? VisualDensity.compact
                : VisualDensity.standard;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      compact ? 8 : 16,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: topGap),
                        SizedBox(
                          height: headerHeight,
                          child: Stack(
                            children: [
                              Center(
                                child: FaIcon(
                                  FontAwesomeIcons.noteSticky,
                                  color: scheme.primary,
                                  size: headerSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 10 : 24),
                        _roundedWrap(
                          _navTile(
                            context,
                            leading: FontAwesomeIcons.pen,
                            title: l10n.note,
                            iconSize: iconSize,
                            density: density,
                            onTap: () => _goNote(context),
                          ),
                        ),
                        SizedBox(height: gap),
                        _roundedWrap(
                          _navTile(
                            context,
                            leading: FontAwesomeIcons.solidStickyNote,
                            title: l10n.motalk,
                            iconSize: iconSize,
                            density: density,
                            onTap: () => _goMoHome(context),
                          ),
                        ),
                        SizedBox(height: gap),
                        _roundedWrap(
                          _navTile(
                            context,
                            leading: FontAwesomeIcons.boxArchive,
                            title: l10n.note_archive,
                            iconSize: iconSize,
                            density: density,
                            onTap: () {
                              _closeDrawer(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ArchivedNotesPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: gap),
                        _roundedWrap(
                          _navTile(
                            context,
                            leading: FontAwesomeIcons.commentDots,
                            title: l10n.momotalk_archive,
                            iconSize: iconSize,
                            density: density,
                            onTap: () {
                              _closeDrawer(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ArchivedChatsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: gap),
                        _buildLabelTile(context, l10n, scheme),
                        const Spacer(),
                        Divider(
                          height: compact ? 8 : 16,
                          color: scheme.onSurface.withValues(alpha: 0.08),
                        ),
                        _roundedWrap(
                          _navTile(
                            context,
                            leading: FontAwesomeIcons.gear,
                            title: l10n.settings,
                            iconSize: iconSize,
                            density: density,
                            onTap: () => _openSettings(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLandscapeDrawer(
    BuildContext context,
    BoxConstraints constraints,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    const padding = 18.0;
    final tileWidth = (constraints.maxWidth - padding * 2 - 10) / 2;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(padding, 10, padding, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.noteSticky,
                color: scheme.primary,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                'Neonote',
                style: TextStyle(
                  fontFamily: 'ResourceHanCN',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _shortNavTile(
                context,
                width: tileWidth,
                icon: FontAwesomeIcons.pen,
                title: l10n.note,
                onTap: () => _goNote(context),
              ),
              _shortNavTile(
                context,
                width: tileWidth,
                icon: FontAwesomeIcons.solidStickyNote,
                title: l10n.motalk,
                onTap: () => _goMoHome(context),
              ),
              _shortNavTile(
                context,
                width: tileWidth,
                icon: FontAwesomeIcons.boxArchive,
                title: l10n.note_archive,
                onTap: () {
                  _closeDrawer(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArchivedNotesPage(),
                    ),
                  );
                },
              ),
              _shortNavTile(
                context,
                width: tileWidth,
                icon: FontAwesomeIcons.commentDots,
                title: l10n.momotalk_archive,
                onTap: () {
                  _closeDrawer(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArchivedChatsPage(),
                    ),
                  );
                },
              ),
              _shortLabelTile(context, width: tileWidth, l10n: l10n),
              _shortNavTile(
                context,
                width: tileWidth,
                icon: FontAwesomeIcons.gear,
                title: l10n.settings,
                onTap: () => _openSettings(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shortNavTile(
    BuildContext context, {
    required double width,
    required FaIconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: 48,
      child: Material(
        color: scheme.onSurface.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FaIcon(icon, size: 18, color: scheme.onSurface),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'ResourceHanCN',
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shortLabelTile(
    BuildContext context, {
    required double width,
    required AppLocalizations l10n,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: 48,
      child: Material(
        color: scheme.onSurface.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _openTagPage(context),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.tags,
                        size: 18,
                        color: scheme.onSurface,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'ResourceHanCN',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AccessibleIconButton(
              tooltip: l10n.tag_create,
              visualDensity: VisualDensity.compact,
              iconSize: 14,
              onPressed: () => _createTag(context, l10n),
              icon: FaIcon(FontAwesomeIcons.add, color: scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTile(
    BuildContext context, {
    required FaIconData leading,
    required String title,
    required double iconSize,
    required VisualDensity density,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      visualDensity: density,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      leading: FaIcon(leading, size: iconSize, color: scheme.onSurface),
      title: Text(title),
      titleTextStyle: const TextStyle(
        fontFamily: 'ResourceHanCN',
        fontSize: _fontSizeSub,
      ),
      textColor: scheme.onSurface,
      horizontalTitleGap: 22,
      onTap: onTap,
    );
  }

  Widget _buildLabelTile(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    return _roundedWrap(
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: Text(
          l10n.label,
          style: const TextStyle(
            fontFamily: 'ResourceHanCN',
            fontSize: _fontSizeSub,
          ),
        ),
        title: const SizedBox.shrink(),
        textColor: scheme.onSurface,
        horizontalTitleGap: 22,
        trailing: AccessibleIconButton(
          tooltip: l10n.tag_create,
          iconSize: DeviceInfo.pt(_iconSizeSmall * 0.75),
          onPressed: () => _createTag(context, l10n),
          icon: FaIcon(FontAwesomeIcons.add, color: scheme.onSurface),
        ),
        onTap: () => _openTagPage(context),
      ),
    );
  }

  Future<void> _createTag(BuildContext context, AppLocalizations l10n) async {
    final name = await showTextInputDialog(
      context,
      title: l10n.tag_create,
      hint: l10n.input_name_hint,
      confirmLabel: l10n.add,
    );
    if (name == null || name.isEmpty) return;
    await NoteStore.addTag(name);
  }

  void _closeDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
    }
  }

  void _goNote(BuildContext context) {
    final navigator = Navigator.of(context);
    _closeDrawer(context);
    if (activePage == AppDrawerPage.note) return;
    navigator.popUntil((route) => route.isFirst);
  }

  void _goMoHome(BuildContext context) {
    final navigator = Navigator.of(context);
    _closeDrawer(context);
    if (activePage == AppDrawerPage.momoTalk) return;
    navigator.popUntil((route) => route.isFirst);
    navigator.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: MoHomePage.routeName),
        builder: (_) => const MoHomePage(),
      ),
    );
  }

  void _openTagPage(BuildContext context) {
    final navigator = Navigator.of(context);
    _closeDrawer(context);
    navigator.push(MaterialPageRoute(builder: (_) => const TagPage()));
  }

  void _openSettings(BuildContext context) {
    _closeDrawer(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MySettingPage()),
    );
  }

  Widget _roundedWrap(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
