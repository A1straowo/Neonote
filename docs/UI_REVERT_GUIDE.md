# 非预期 UI 改动回退清单

以下改动不属于本补丁，建议逐项回退。

## 1. 抽屉右上角关闭图标

不应在侧边抽屉标题行右侧添加关闭按钮。Drawer 已经支持：

- 点击遮罩关闭；
- 系统返回键关闭；
- 左滑关闭。

回退方式：

- 在 `lib/widgets/app_drawer.dart` 搜索 `Icons.close`、`close_rounded`、`IconButton`；
- 删除仅用于关闭 drawer 的那个 `IconButton`；
- 保留原有的导航项和标签项。

## 2. “界面”里出现两个主题控制

同一个设置分组里只能有一个主题入口。不要同时保留：

- 旧的“深色主题”开关；
- 新的 System / Light / Dark 主题选择栏。

推荐直接保留原“深色主题”开关，因为 APK 1.0.0 原本就是这一行为。若以后确实需要跟随系统，再把原开关替换成单一的三态控件，而不是叠加两个。

回退方式：

- 删除 `ThemeModeSelector` 或新的主题 `ListTile`；
- 恢复原 `Switch` 绑定的 `darkMode` 逻辑；
- 搜索 `theme`、`ThemeMode`、`darkMode`，确认设置分组中只有一处。

## 3. 便签出现额外带颜色的文本框

`NoteComponentCard` 应保持原有卡片外观。不要给便签组件再包一层带背景色、边框或阴影的 `Container` / `Card`。

回退方式：

- 在 `lib/widgets/note_component_card.dart` 中检查新增的 `Container`、`BoxDecoration`、`color:`、`Card`；
- 删除装饰性外层，只保留原有 `NoteComponentCard` 结构；
- 颜色只应用于语义明确的元素，例如 AI Markdown 代码块，不要包裹普通便签文本。

## 4. 不要引入全局视觉重设

如果只是修复功能或布局 bug，不要同时替换全局 `ThemeData`、卡片主题、输入框主题、按钮主题。全局主题改动会意外影响所有页面，造成“到处都变了”的感觉。

回退方式：

- 恢复原 `ThemeData(colorScheme:, fontFamily:, pageTransitionsTheme:, splashFactory:, useMaterial3:)`；
- 删除新增的 `cardTheme`、`dialogTheme`、`bottomSheetTheme`、`inputDecorationTheme` 等覆盖；
- 仅在明确需要修复的单个组件内做局部调整。
