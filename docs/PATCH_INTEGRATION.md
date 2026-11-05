# Patch 接入说明

本 patch 只新增文件，因此可直接应用到源码根目录：

```bash
git apply Neonote_1.0.0_ux_optimization.patch
```

新增模块：

| 文件 | 用途 |
|---|---|
| `lib/ui/app_layout.dart` | 断点、内容区最大宽度、自适应弹层/弹窗 |
| `lib/ui/neonote_theme.dart` | 完整 Material 3 主题、ThemeExtension、系统主题解析 |
| `lib/widgets/empty_state.dart` | 统一样式的空状态与列表内空状态 |
| `lib/widgets/accessible_icon_button.dart` | 强制 tooltip 的可访问图标按钮 |
| `lib/search/note_search.dart` | 全文搜索页与搜索结果模型 |
| `lib/deepseek/ai_markdown.dart` | 零依赖 Markdown 渲染器 |
| `lib/deepseek/ai_message_actions.dart` | AI 回复复制/插入/重新生成操作栏 |
| `lib/services/note_export_service.dart` | Markdown / JSON 导出 |
| `lib/ui/canvas_grid_painter.dart` | 对齐坐标轴、批量绘制网格/点阵并缓存几何 |
| `lib/widgets/theme_mode_selector.dart` | 不横向滚动的自适应主题三态选择器 |

## 1. 空状态

在 `lib/note_editor.dart` 的 `_buildBody` 中，把组件为空时返回的 `SizedBox` 替换为：

```dart
if (_components.isEmpty) {
  final l = AppLocalizations.of(context)!;
  return EmptyState(
    icon: Icons.edit_note_rounded,
    title: l.no_text_content,
    message: l.ai_welcome,
    action: FilledButton.icon(
      onPressed: () => _openWorkbench(context, NoteComponentType.text),
      icon: const Icon(Icons.add_rounded),
      label: Text(l.add),
    ),
  );
}
```

如果现有 `_openWorkbench` 签名不同，把 `onPressed` 换成当前悬浮球菜单使用的“添加文本组件”回调即可。

## 2. 主题统一

在 `lib/main.dart` 的 `buildTheme` / 配色函数中改为：

```dart
final theme = buildNeonoteTheme(
  colorScheme: colorScheme,
  fontFamily: 'ResourceHanCN',
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _NeonotePageTransitionsBuilder(),
    },
  ),
);
```

`MaterialApp`：

```dart
theme: buildNeonoteTheme(colorScheme: lightScheme, fontFamily: 'ResourceHanCN'),
darkTheme: buildNeonoteTheme(colorScheme: darkScheme, fontFamily: 'ResourceHanCN'),
themeMode: neonoteThemeModeFromSetting(
  storedMode: settingsBox.get('themeMode'),
  legacyDarkMode: settingsBox.get('darkMode', defaultValue: false),
),
```

设置页的主题下拉/分段按钮增加 `System` 选项，并把 `themeMode` 写成 `system` / `light` / `dark`。

## 3. 搜索

1. 在主页 `AppBar.actions` 增加：

```dart
IconButton(
  tooltip: '搜索笔记',
  icon: const Icon(Icons.search_rounded),
  onPressed: () async {
    final entries = NoteStore.activeComponents()
        .map((component) => NoteSearchEntry.fromMap(component.toMap()))
        .toList(growable: false);

    final selected = await Navigator.of(context).push<NoteSearchEntry>(
      MaterialPageRoute(
        builder: (_) => NoteSearchPage(
          entries: entries,
          onSelected: (result) => Navigator.of(context).pop(result),
        ),
      ),
    );
    if (selected != null) {
      // 根据 selected.id 滚动到对应卡片，或调用当前卡片的编辑/定位方法。
    }
  },
)
```

标签名可在构造 `NoteSearchEntry` 时传入映射：

```dart
NoteSearchEntry.fromMap(
  component.toMap(),
  tagNames: {for (final tag in NoteStore.tags()) tag.id: tag.name},
)
```

## 4. AI 回复 Markdown 与操作栏

在 `lib/deepseek/ai_chat_page.dart` 的 `_buildMessage` 中：

```dart
// 原：SelectableText(message.content, ...)
AiMarkdownText(message.content)

// 在回复气泡下方加入：
if (message.role == 'assistant')
  AiMessageActions(
    content: message.content,
    onInsert: () => _insertIntoNotes(message.content),
    onRegenerate: _isSending ? null : () => _regenerateLastReply(),
  )
```

`_regenerateLastReply()` 可按现有 `_send` 的逻辑复用：删除最后一条 assistant 消息，用相同上下文重新请求；若暂时不实现，只传 `onInsert` 也能获得复制/插入能力。

## 5. 导出/备份

在设置页新增两个 tile，或在存储页加入按钮：

```dart
final maps = NoteStore.activeComponents().map((e) => e.toMap()).toList();
await NoteExportService.copyMarkdownToClipboard(maps, title: 'Neonote');
final file = await NoteExportService.saveBackupToFile(components: maps);
```

建议随后加入系统分享面板（需要 `share_plus`）以及导入流程。

## 6. 绘图画布网格/点阵

`lib/ui/canvas_grid_painter.dart` 提供两个可直接替换的实现：

- `DrawingCanvasGridPainter`：替换 `workbench.dart` 中的 `_InfiniteCanvasBackgroundPainter`。
- `NoteCardGridPainter`：替换 `workbench.dart` 中的 `_NoteGridPainter`。

绘图页原构造大致为：

```dart
_InfiniteCanvasBackgroundPainter(
  widget.canvasStyle,     // "none" / "grid" / "dots"
  gridColor,
  axisColor,
)
```

替换时映射为：

```dart
DrawingCanvasGridPainter(
  style: switch (canvasStyle) {
    'dots' => DrawingCanvasGridStyle.dots,
    'grid' => DrawingCanvasGridStyle.grid,
    _ => DrawingCanvasGridStyle.none,
  },
  gridColor: gridColor,
  axisColor: axisColor,
  spacing: 48,
  majorEvery: 5,
  devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
)
```

并把背景 `CustomPaint` 包进 `RepaintBoundary`：

```dart
RepaintBoundary(
  child: CustomPaint(
    painter: DrawingCanvasGridPainter(...),
    isComplex: true,
    willChange: false,
    size: Size.infinite,
  ),
)
```

要点：

- 新 painter 以 `size.center` 为唯一原点，网格线和坐标轴共用 48px 间距，轴线必然落在网格交点上。
- 点阵与网格共用同一 spacing，切换模式时坐标系统不跳变。
- 网格几何缓存在 `Float32List` 中，一次 `drawRawPoints` 绘制。
- 点阵模式不再逐点绘制，而是用透明 tile 生成 `ImageShader` 并一次 `drawPaint` 铺满画布；DPR 必须从 `MediaQuery` 传入以保证清晰度。
- 点阵 tile 的四角分别绘制四分之一个圆，平铺时自动拼成完整圆点；shader matrix 以 `size.center` 为相位原点，因此点阵与坐标轴严格对齐。
- 若背景需要随画布一起平移缩放，请保持 `CustomPaint` 位于 `InteractiveViewer` 的内容层；若背景只是视口装饰，则移到 `InteractiveViewer` 外，避免缩放时重复绘制。

### 还必须处理实时笔迹的 setState

当前 `_updateStroke` 的画笔分支在每个 pointer move 都会 `setState`，导致整页组件树和背景 painter 被重新创建。即使点阵使用 shader，整页重建仍会吃掉帧预算。

把 `_WorkbenchDrawingPainter` 改为由 notifier 驱动：

```dart
class _WorkbenchDrawingPainter extends CustomPainter {
  _WorkbenchDrawingPainter(
    /* existing params */, {
    required Listenable repaint,
  }) : super(repaint: repaint);

  // ...
}
```

在 `_DrawingWorkbenchState` 中复用已有的 `FrameCoalescedNotifier`：

```dart
_LiveStrokePainter(
  strokes,
  _draftPoints,
  color,
  width,
  repaint: _liveStrokeRepaint,
);
```

并把 `_updateStroke` 中修改点集后的 `setState(() { ... })` 改成：

```dart
_liveStrokeRepaint.notifySoon();
```

仅在以下时机调用 `setState`：

- 按下开始新笔画；
- 抬手结束笔画；
- 撤销/重做；
- 切换工具、颜色或背景模式。

这样拖动时只重绘笔迹 `RepaintBoundary`，不会重建绘图页和点阵背景。

## 7. 主题选择栏不要横向滚动

把设置页中原来“深色模式”的 `Switch` 替换为：

```dart
ThemeModeSelector(
  value: neonoteThemeModeFromSetting(
    storedMode: box.get('themeMode'),
    legacyDarkMode: box.get('darkMode', defaultValue: false),
  ),
  label: l.theme,
  systemLabel: l.system,
  lightLabel: l.light,
  darkLabel: l.dark,
  onChanged: (mode) async {
    await box.put('themeMode', switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    });
  },
)
```

不要再写成：

```dart
// 不推荐：三项设置被迫左右滑动
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(children: [...]),
)
```

`ThemeModeSelector` 的行为：

- 正常宽度：三个等宽选项，`Expanded` 平分，不产生横向滚动；
- 宽度小于 380～420dp 或字体缩放超过 1.35：自动降级为全宽下拉菜单；
- 每个选项都有文字、图标、选中态、Tooltip 和 Semantics 标签。

## 8. 图标按钮可访问性

把笔记卡片、归档页、抽屉中的裸 `IconButton` 替换为：

```dart
AccessibleIconButton(
  tooltip: l.edit,
  icon: const Icon(Icons.edit_outlined),
  onPressed: onEdit,
)
```

tooltip 使用现有 `AppLocalizations` 字段；不要硬编码中文。

## 9. 大屏/平板

- 设置页、DeepSeek 设置页、归档页：用 `ContentPane` 包住 `ListView` 内容。
- AI 历史、学生/头像/颜色选择：把 `showModalBottomSheet` 替换为 `showAdaptiveSurface`。
- 笔记卡片宽度在 `AppBreakpoints.isExpanded(context)` 时限制为 `AppBreakpoints.wideContentMax`，避免 1200px 以上一行文字过长。

## 10. 验证建议

```bash
flutter analyze
flutter test
flutter run -d <device>
```

重点回归：

- 手机 320dp、375dp、平板 800dp、横屏。
- 系统字体 200% 与用户自定义缩放最大档。
- 深浅色、动态色、六种语言。
- 首次启动空状态、搜索无结果、导出空笔记、AI 复制失败。
