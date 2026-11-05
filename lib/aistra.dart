import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/ui/app_layout.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _version = '1.0.1';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: l10n.close,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          l10n.about,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: ContentPane(
          maxWidth: 760,
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHero(context, l10n, scheme),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth >= 560
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _InfoCard(
                            icon: Icons.person_outline_rounded,
                            label: l10n.developer,
                            value: '筱梦碎星',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _InfoCard(
                            icon: Icons.new_releases_outlined,
                            label: l10n.version,
                            value: _version,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildLicenseCard(context, l10n, scheme),
                const SizedBox(height: 36),
                Text(
                  '© 2026 筱梦碎星',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.42),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.secondaryContainer],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -36,
            child: _decorativeCircle(
              size: 150,
              color: scheme.onPrimaryContainer.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            left: -56,
            bottom: -76,
            child: _decorativeCircle(
              size: 180,
              color: scheme.onPrimaryContainer.withValues(alpha: 0.045),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 78,
                    height: 78,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.noteSticky,
                      size: 38,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Neonote',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'v$_version',
                    style: TextStyle(
                      fontFamily: 'ResourceHanCN',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Text(
                    l10n.about_tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ResourceHanCN',
                      fontSize: 15,
                      height: 1.55,
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildLicenseCard(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          showLicensePage(
            context: context,
            applicationName: 'Neonote',
            applicationVersion: _version,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              _iconBadge(scheme, Icons.description_outlined),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.open_source_license,
                      style: TextStyle(
                        fontFamily: 'ResourceHanCN',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'MIT License',
                      style: TextStyle(
                        fontFamily: 'ResourceHanCN',
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _iconBadge(scheme, icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ResourceHanCN',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _iconBadge(ColorScheme scheme, IconData icon) {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: scheme.primaryContainer.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, size: 22, color: scheme.onPrimaryContainer),
  );
}
