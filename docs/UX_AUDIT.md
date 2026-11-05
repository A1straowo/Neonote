# Neonote 1.0.0 功能与 UI 审查

## 1. 审查范围与方法

- APK：`Neonote_1.0.0.apk`
  - package：`io.aistra.neonote.note`
  - versionName：`1.0.0` / versionCode：`2001`
  - minSdk 24 / targetSdk 36 / 仅提供 `arm64-v8a` 原生库
- 这是 Flutter release AOT 应用。通过 APK 资源、AOT 快照中的 source path、国际化字符串、类/函数符号以及 Blutter 反汇编的 Widget 构建树还原页面结构。
- 由于附件只有 APK，没有原始工程与 `pubspec.yaml`，本 patch 采用“只新增文件”的方式，保证能直接 `git apply` 到源码根目录；具体接入点见 `docs/PATCH_INTEGRATION.md`。

## 2. 功能面现状

已具备：

- 单工作区卡片式笔记：文本、清单、绘图、图片、录音。
- 文本格式、字号/颜色、对齐、插入时间/分割线/清单/图片/绘图、撤销/重做、字数统计。
- 标签、置顶、标记、归档、删除、搜索标签。
- 自动保存、恢复草稿、写入失败重试队列。
- DeepSeek 对话：模型/推理/模式、图片与语音附件、历史会话、插入笔记。
- MomoTalk：分组会话、角色/学生、头像、气泡样式、消息编辑/重排、截图、图片、AI 回复。
- 六种语言、动态取色、深浅色、字体缩放、手势配置、存储统计、开源许可。

## 3. 优先问题清单

### P0 — 首次启动/空笔记是空白页

**证据**：`note_editor.dart::_buildBody` 在组件列表为空时直接返回 `SizedBox`。因此首次打开时没有任何标题、插画、说明或主操作按钮，用户只能猜测右下角悬浮球可添加内容。

**影响**：新用户流失、无法理解卡片与悬浮球的关系。

**建议**：加入空状态（图标 + 标题 + 说明 + “添加第一段内容”按钮），并在空状态中解释悬浮球/侧边栏。

### P0 — 没有全文搜索

**证据**：`search.dart` 只有 `TagPage`；国际化中只有 `search_students`、`ai_search_history`，没有搜索笔记内容的入口。

**影响**：卡片越多越难找到内容，只能靠滚动和标签。

**建议**：在主页 AppBar 增加搜索按钮，搜索标题/正文/清单项/标签；结果高亮关键词，支持标签过滤，点击定位到卡片。

### P0 — 没有导出/备份/恢复

**证据**：全部本地化字符串中没有 export/import/backup；数据依赖 Hive、SQLite 和本地媒体目录。应用被卸载或清除数据后无法恢复。

**影响**：用户数据资产风险高；更换设备时迁移成本极高。

**建议**：至少提供 Markdown / JSON 导出；后续加入导入与文件分享。


### P1 — 绘图画布：坐标轴与网格原点不一致

**证据**：`_InfiniteCanvasBackgroundPainter.paint` 中：

- 网格线从画布左上角 `0 + n * 48` 开始绘制；
- 坐标轴却画在 `size.center`；
- 点阵模式的点从 `26 + n * 52` 开始绘制，且与网格模式使用不同的 48/52 间距。

因此只要画布宽或高不是 48 的整数倍，中心坐标轴就会落在两条网格线之间；切换到点阵模式后，点阵与坐标轴、网格模式也不在同一套坐标系统上。

**建议**：所有画布图案统一以 `size.center` 为原点，网格、点阵、坐标轴共用同一 `spacing`；坐标轴必须穿过 `(originX + n*spacing, originY + m*spacing)` 的网格交点。

### P1 — 绘图画布：点阵模式明显卡顿

**证据**：

- `_InfiniteCanvasBackgroundPainter` 的点阵分支在每次 `paint` 时用 growable `List<Offset>` 逐点构造点集，每个点都会分配一个 `Offset` 对象，再调用 `drawPoints`。
- 点在宽高两个方向按固定间距铺满，开销为 `O(width/spacing * height/spacing)`；大画布或每帧重绘时会产生大量对象分配和 GC。
- 笔记卡片背景使用的 `_NoteGridPainter` 更严重：点阵模式下在双重循环里逐点调用 `canvas.drawCircle`，每个点都是一次独立绘制调用。
- 绘图页的静态背景 `CustomPaint` 没有包在 `RepaintBoundary` 中，而笔迹图层有，交互触发的父级重建容易让背景重复绘制。

**补充证据：只把逐点 `Offset` 改为 `drawRawPoints` 仍不够**

- 点阵仍然是成千上万个抗锯齿实心点；GPU 每帧仍要栅格化全部点。
- `_DrawingWorkbenchState._updateStroke` 在画笔移动分支中调用 `setState`，每收到一个 pointer move 就重建整个绘图页组件树，重新创建背景 `CustomPaint` 与其 painter。
- 背景 `CustomPaint` 不是 `RepaintBoundary`，因此父级重建/兄弟图层重绘时很容易连背景一起重新栅格化。
- 所以“减少对象分配”只能降低 Dart/GC 抖动，不能保证降低 GPU 栅格化开销。

**最终建议**：

1. 点阵模式用一张透明小 tile 生成 `ui.ImageShader`，再以 `TileMode.repeated` 一次 `drawPaint` 铺满画布。这样不管画布多大、点有多少，GPU 绘制调用数都是常数，而不是上万个抗锯齿圆点。
2. tile 四角画四分之一个圆，平铺后自然拼成完整点，并可通过 shader matrix 把点的相位严格对齐到 `size.center`。
3. 网格模式则继续用缓存 `Float32List` + `drawRawPoints`。
4. 把实时笔迹层与背景分离：`_WorkbenchDrawingPainter` 的构造函数增加 `super(repaint: liveStrokeNotifier)`；`_updateStroke` 修改点集后只 `notifySoon()`，不要 `setState`。只在笔画开始/结束、工具切换、撤销/重做时重建页面。
5. 背景包 `RepaintBoundary`，设置 `isComplex: true`、`willChange: false`。
6. 如果背景不需要随画布平移缩放，移到 `InteractiveViewer` 外层，避免缩放时重复重绘。

### P1 — AI 回复只按纯文本渲染

**证据**：`ai_chat_page.dart::_buildMessage` 使用 `SelectableText`；APK 中不存在 Markdown 渲染依赖。

**影响**：DeepSeek 返回的标题、列表、代码块、行内代码和粗体都会显示原始符号，阅读和复制代码体验差。

**建议**：使用轻量 Markdown 渲染器；保留可选择文本；代码块增加复制按钮。

### P1 — AI 消息缺少复制、重新生成、停止/取消

**证据**：`_buildMessage` 只有“插入笔记”按钮；`deepseek_service.dart` 请求中固定 `"stream": false`；页面没有中止请求的能力。

**影响**：无法快速复用回复；回答不理想时只能重新输入；长请求只能等待。

**建议**：消息操作栏增加复制/重新生成/插入；请求期间显示“停止”；后续升级为 SSE 流式输出。

### P1 — API Key 以明文存入 Hive

**证据**：`DeepseekConfig.save/load` 使用 `HiveThemeBox` 的 `deepseek_api_key` 字符串键。

**影响**：Root / 备份提取 / 调试环境下密钥可能泄露。

**建议**：迁移到 Android Keystore 支持的 secure storage；至少在设置页提示“密钥仅保存在本机”并提供清除。

### P1 — 只有一套全局笔记组件，缺少多笔记/笔记本

**证据**：主页直接是 `NoteEditorView`，`NoteStore.activeComponents()` 是全局列表；没有笔记列表页、笔记本页或文档选择器（现有 `_DocumentSelectionDialog` 用于文本段落选择，不是笔记选择）。

**影响**：所有内容混在一个空间里；长期使用后管理成本高。

**建议**：引入 `notebook/documentId` 维度。短期可先增加“归档”之外的“收藏/筛选/搜索”以降低压力。

### P2 — 系统主题模式缺失

**证据**：`MaterialApp.themeMode` 只根据布尔值 `darkMode` 选择 `ThemeMode.dark` 或 `ThemeMode.light`，设置页没有“跟随系统”。

**建议**：设置增加 System / Light / Dark 三态，并兼容旧 `darkMode` 布尔值。

### P2 — 主题选择栏不应依赖左右滑动

**问题**：把“深色模式”开关改成 System / Light / Dark 三态选择栏后，如果实现为横向 `SingleChildScrollView`、横向 `ListView` 或固定宽度 `Row`，在窄屏和大字号下会溢出，用户必须左右滑动才能看到第三个选项。三项主题选择是低频、强互斥设置，横向滑动既没有必要，也会隐藏选项、降低可发现性和 TalkBack 可达性。

**建议**：

- 三项在空间足够时使用等宽分段控件，每个选项 `Expanded` 平分宽度；
- 窄屏或字体缩放较大时，降级为全宽下拉菜单，而不是横向滚动；
- 每个选项必须有明确文字、选中态和语义标签；
- 不要使用固定像素宽度的 `Row` 或只显示图标的分段栏。

### P2 — 响应式布局不统一

**证据**：侧边栏为横屏做了独立布局，但设置、DeepSeek 设置、归档列表等仍直接 `ListView` 全宽铺满；AI 历史、选择器等无论屏幕大小都使用底部弹层。

**建议**：统一断点与最大内容宽度；大屏使用居中内容区和 Dialog，手机使用底部弹层。

### P2 — 图标按钮缺少可见标签/无障碍名称

**证据**：`note_component_card.dart`、`app_drawer.dart`、`search.dart`、`archive_pages.dart` 等多个页面包含大量 `IconButton`，而这些文件中没有 tooltip 参数；TalkBack 只能读出“按钮”。

**建议**：所有图标按钮必须传入 tooltip；笔记卡片操作尽量改为带文字菜单。

### P2 — ThemeData 过于简陋，页面各自定义样式

**证据**：`MyApp::buildTheme` 只设置了 `colorScheme`、`fontFamily`、`pageTransitionsTheme`、`splashFactory`、`useMaterial3`，没有 `appBarTheme`、`cardTheme`、`inputDecorationTheme`、按钮主题、弹窗/底部弹层主题、SnackBar 主题等。

**影响**：卡片、输入框、按钮、弹窗圆角和间距不一致；修改设计规范需要改很多页面。

**建议**：集中到 `buildNeonoteTheme()`，用 ThemeExtension 管理间距和圆角。

### P2 — 键盘/桌面可用性不足

- 没有快捷键帮助或命令面板。
- 大量操作依赖滑动手势，没有等价的可发现按钮。
- 平板/桌面没有双栏布局，也没有 Hover/焦点态统一处理。

### P2 — 大字号下的固定高度/固定行布局风险

**证据**：卡片图标区、附件栏、胶囊菜单、多行 `Row` 中存在大量固定尺寸；虽然文本缩放被限制在 0.8～2.0，但在 2.0 倍及较长语言文本下仍可能 overflow。

**建议**：把固定 `Row` 改为 `Wrap`/`OverflowBar`；关键行加 `Flexible` + `maxLines` + `ellipsis`；增加 golden/integration 测试覆盖 200% 字号。

## 4. 建议实施顺序

1. 空状态 + 搜索入口 + 导出。
2. AI Markdown + 消息操作栏 + 请求取消。
3. 主题统一 + 响应式内容区 + 弹窗/底部弹层适配。
4. 图标按钮 tooltip 与 200% 字号回归。
5. 多笔记模型、系统主题、Keystore、云同步等结构性改造。
