import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A dependency-free Markdown renderer for DeepSeek replies.
///
/// The current AI page renders every reply with `SelectableText`, so headings,
/// lists, code fences, inline code and bold text are shown as raw punctuation.
/// Keeping this renderer local avoids pulling in a large Markdown dependency and
/// still covers the syntax produced by chat models.
class AiMarkdownText extends StatelessWidget {
  const AiMarkdownText(
    this.data, {
    super.key,
    this.style,
    this.codeStyle,
    this.onLinkTap,
  });

  final String data;
  final TextStyle? style;
  final TextStyle? codeStyle;
  final ValueChanged<String>? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = style ?? theme.textTheme.bodyLarge;
    final inlineCodeStyle =
        codeStyle ??
        bodyStyle?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          fontSize: (bodyStyle.fontSize ?? 14) * 0.94,
        );
    final blocks = _parseBlocks(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < blocks.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          blocks[index].build(
            context,
            bodyStyle: bodyStyle,
            codeStyle: inlineCodeStyle,
            onLinkTap: onLinkTap,
          ),
        ],
      ],
    );
  }

  static List<_MarkdownBlock> _parseBlocks(String source) {
    final normalized = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized.split('\n');
    final blocks = <_MarkdownBlock>[];
    final paragraph = <String>[];
    final code = <String>[];
    var inCode = false;
    String? codeLanguage;

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      blocks.add(_ParagraphBlock(paragraph.join('\n')));
      paragraph.clear();
    }

    void flushCode() {
      if (!inCode && code.isEmpty) return;
      blocks.add(_CodeBlock(code.join('\n'), language: codeLanguage));
      code.clear();
      codeLanguage = null;
      inCode = false;
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      final fence = RegExp(r'^```\s*([A-Za-z0-9_+-]*)\s*$').firstMatch(line);
      if (fence != null) {
        if (inCode) {
          flushCode();
        } else {
          flushParagraph();
          inCode = true;
          codeLanguage = fence.group(1)?.isEmpty == true
              ? null
              : fence.group(1);
        }
        continue;
      }

      if (inCode) {
        code.add(rawLine);
        continue;
      }

      if (line.trim().isEmpty) {
        flushParagraph();
        continue;
      }

      final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line);
      if (heading != null) {
        flushParagraph();
        blocks.add(
          _HeadingBlock(
            heading.group(2)!.trim(),
            level: heading.group(1)!.length,
          ),
        );
        continue;
      }

      if (RegExp(r'^\s*(?:---+|\*\*\*+|___+)\s*$').hasMatch(line)) {
        flushParagraph();
        blocks.add(const _DividerBlock());
        continue;
      }

      final quote = RegExp(r'^\s*>\s?(.*)$').firstMatch(line);
      if (quote != null) {
        flushParagraph();
        blocks.add(_QuoteBlock(quote.group(1)!));
        continue;
      }

      final bullet = RegExp(r'^\s*[-*+]\s+(.*)$').firstMatch(line);
      if (bullet != null) {
        flushParagraph();
        blocks.add(_ListBlock(bullet.group(1)!, ordered: false));
        continue;
      }

      final ordered = RegExp(r'^\s*(\d+)[.)]\s+(.*)$').firstMatch(line);
      if (ordered != null) {
        flushParagraph();
        blocks.add(
          _ListBlock(
            ordered.group(2)!,
            ordered: true,
            index: int.tryParse(ordered.group(1)!),
          ),
        );
        continue;
      }

      paragraph.add(line);
    }

    if (inCode) flushCode();
    flushParagraph();
    return blocks;
  }
}

abstract class _MarkdownBlock {
  const _MarkdownBlock();

  Widget build(
    BuildContext context, {
    required TextStyle? bodyStyle,
    required TextStyle? codeStyle,
    ValueChanged<String>? onLinkTap,
  });
}

class _ParagraphBlock extends _MarkdownBlock {
  const _ParagraphBlock(this.text);

  final String text;

  @override
  Widget build(
    BuildContext context, {
    required TextStyle? bodyStyle,
    required TextStyle? codeStyle,
    ValueChanged<String>? onLinkTap,
  }) {
    return SelectableText.rich(
      TextSpan(
        style: bodyStyle,
        children: _parseInline(text, codeStyle, onLinkTap),
      ),
    );
  }
}

class _HeadingBlock extends _MarkdownBlock {
  const _HeadingBlock(this.text, {required this.level});

  final String text;
  final int level;

  @override
  Widget build(
    BuildContext context, {
    required TextStyle? bodyStyle,
    required TextStyle? codeStyle,
    ValueChanged<String>? onLinkTap,
  }) {
    final theme = Theme.of(context);
    final base = switch (level) {
      1 => theme.textTheme.headlineSmall,
      2 => theme.textTheme.titleLarge,
      3 => theme.textTheme.titleMedium,
      _ => theme.textTheme.titleSmall,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SelectableText.rich(
        TextSpan(
          style: base?.copyWith(fontWeight: FontWeight.w700),
          children: _parseInline(text, codeStyle, onLinkTap),
        ),
      ),
    );
  }
}

class _QuoteBlock extends _MarkdownBlock {
  const _QuoteBlock(this.text);

  final String text;

  @override
  Widget build(
    BuildContext context, {
    required TextStyle? bodyStyle,
    required TextStyle? codeStyle,
    ValueChanged<String>? onLinkTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText.rich(
        TextSpan(
          style: bodyStyle?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          children: _parseInline(text, codeStyle, onLinkTap),
        ),
      ),
    );
  }
}

class _ListBlock extends _MarkdownBlock {
  const _ListBlock(this.text, {required this.ordered, this.index});

  final String text;
  final bool ordered;
  final int? index;

  @override
  Widget build(
    BuildContext context, {
    required TextStyle? bodyStyle,
    required TextStyle? codeStyle,
    ValueChanged<String>? onLinkTap,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            ordered ? '${index ?? 1}.' : '•',
            style: bodyStyle?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: SelectableText.rich(
            TextSpan(
              style: bodyStyle,
              children: _parseInline(text, codeStyle, onLinkTap),
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeBlock extends _MarkdownBlock {
  const _CodeBlock(this.code, {this.language});

  final String code;
  final String? language;

  @override
  Widget build(
    BuildContext context, {
    required TextStyle? bodyStyle,
    required TextStyle? codeStyle,
    ValueChanged<String>? onLinkTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: theme.colorScheme.surfaceContainerHigh,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    language?.isNotEmpty == true ? language! : 'code',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied')),
                    );
                  },
                  icon: const Icon(Icons.copy_all_rounded, size: 18),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code.isEmpty ? ' ' : code,
              style: codeStyle?.copyWith(
                backgroundColor: Colors.transparent,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerBlock extends _MarkdownBlock {
  const _DividerBlock();

  @override
  Widget build(
    BuildContext context, {
    required TextStyle? bodyStyle,
    required TextStyle? codeStyle,
    ValueChanged<String>? onLinkTap,
  }) {
    return const Divider(height: 20);
  }
}

List<InlineSpan> _parseInline(
  String text,
  TextStyle? codeStyle,
  ValueChanged<String>? onLinkTap,
) {
  final pattern = RegExp(
    r'(`[^`\n]+`|\*\*[^*\n]+\*\*|__[^_\n]+__|~~[^~\n]+~~|\*[^*\n]+\*|_[^_\n]+_|\[[^\]\n]+\]\([^)\n]+\))',
  );
  final spans = <InlineSpan>[];
  var cursor = 0;

  for (final match in pattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }
    final token = match.group(0)!;
    if (token.startsWith('`') && token.endsWith('`')) {
      spans.add(
        TextSpan(text: token.substring(1, token.length - 1), style: codeStyle),
      );
    } else if (token.startsWith('**') || token.startsWith('__')) {
      spans.add(
        TextSpan(
          text: token.substring(2, token.length - 2),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    } else if (token.startsWith('~~')) {
      spans.add(
        TextSpan(
          text: token.substring(2, token.length - 2),
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        ),
      );
    } else if (token.startsWith('*') || token.startsWith('_')) {
      spans.add(
        TextSpan(
          text: token.substring(1, token.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    } else {
      final link = RegExp(r'^\[([^\]]+)\]\(([^)]+)\)$').firstMatch(token);
      if (link != null) {
        final label = link.group(1)!;
        final url = link.group(2)!;
        if (onLinkTap != null) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () => onLinkTap(url),
                child: Text(
                  label,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: '$label ($url)',
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
      } else {
        spans.add(TextSpan(text: token));
      }
    }
    cursor = match.end;
  }

  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor)));
  }
  return spans;
}
