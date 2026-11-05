# DeepSeek 单条消息操作补丁说明

目标：

- 长按/点击单条消息打开操作菜单；
- 支持复制、选择文本、修改、重新生成、删除；
- 重新生成只重新请求 assistant 文本，不重复发送用户消息；
- 打开会话或切换历史会话后，自动定位到最后一条消息；
- 不增加侧边栏、侧滑面板或横向消息滚动。

## 新增文件

`lib/deepseek/message_action_sheet.dart`

包含：

- `showAiMessageActionSheet`
- `copyAiMessageText`
- `showSelectableMessageDialog`
- `showEditAiMessageDialog`
- `confirmDeleteAiMessage`
- `confirmRegenerateAiMessage`

## 1. 给消息构建器增加索引

把 `_buildMessage` 改为接收消息下标：

```dart
Widget _buildMessage(int index, DeepseekMessage message) {
  // ...
}
```

ListView.builder 调用：

```dart
itemBuilder: (context, index) => _buildMessage(index, _messages[index]),
```

## 2. 给消息气泡加长按菜单

在消息外层增加：

```dart
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onLongPress: () => _openMessageActions(index),
  child: existingMessageBubble,
)
```

不要只让文字区域响应长按，否则图片/附件消息无法弹出菜单。

## 3. 处理单条消息操作

```dart
Future<void> _openMessageActions(int index) async {
  if (index < 0 || index >= _messages.length) return;
  final message = _messages[index];
  final isAssistant = message.role == 'assistant';
  final hasFollowing = index < _messages.length - 1;

  final action = await showAiMessageActionSheet(
    context,
    isAssistant: isAssistant,
    hasFollowingMessages: hasFollowing,
  );
  if (!mounted || action == null) return;

  switch (action) {
    case AiMessageAction.copy:
      await copyAiMessageText(context, message.content);
      break;

    case AiMessageAction.selectText:
      await showSelectableMessageDialog(context, text: message.content);
      break;

    case AiMessageAction.edit:
      final edited = await showEditAiMessageDialog(
        context,
        initialText: message.content,
      );
      if (!mounted || edited == null || edited == message.content) return;
      setState(() => message.content = edited);
      await _persistConversationSafely();
      break;

    case AiMessageAction.regenerate:
      if (!isAssistant) return;
      final confirmed = await confirmRegenerateAiMessage(
        context,
        hasFollowingMessages: hasFollowing,
      );
      if (!mounted || !confirmed) return;
      await _regenerateAt(index);
      break;

    case AiMessageAction.delete:
      final confirmed = await confirmDeleteAiMessage(context);
      if (!mounted || !confirmed) return;
      setState(() => _messages.removeAt(index));
      await _persistConversationSafely();
      break;
  }
}
```

## 4. 单条消息重新生成

只允许 assistant 消息重新生成。用户消息不重新发送。

如果被重新生成的消息后面还有消息，先删除后面的消息，因为上下文已经改变。

```dart
Future<void> _regenerateAt(int index) async {
  if (_isSending) return;
  if (index < 0 || index >= _messages.length) return;
  if (_messages[index].role != 'assistant') return;

  final userIndex = _messages.lastIndexWhere(
    (message) => message.role == 'user',
    index - 1,
  );
  if (userIndex < 0) return;

  setState(() {
    // 删除选中回复以及它之后的消息。
    _messages.removeRange(index, _messages.length);
  });

  await _persistConversationSafely();
  _scheduleScrollToBottom(animate: false);

  // 复用现有请求逻辑：只使用最后一条 user 消息及之前的历史。
  await _requestAssistantReply();
}
```

如果暂不想改变后续消息，可以只在 `index == _messages.length - 1` 时显示“重新生成”，这与当前 `_regenerateLastReply` 行为一致。

## 5. 打开会话后定位到最后一条消息

当前 `_loadLatestConversation` 只加载消息，没有滚动到底部；历史会话选择后有一个 `_scrollToBottom()`，但初始打开页面时没有。

增加：

```dart
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
```

调用位置：

- `_loadLatestConversation()` 完成 `_applyConversation(...)` 后；
- `_applyConversation()` 完成 setState 后；
- `_showHistory()` 选择会话后；
- `_send()` 和 `_requestAssistantReply()` 追加消息后。

如果在 `_applyConversation` 内部统一调用，必须用 `addPostFrameCallback`，否则 `maxScrollExtent` 还是旧值。

## 6. 不要侧边滑动栏

- 不使用 `Drawer`、`endDrawer` 或侧滑历史面板；
- 历史会话继续使用 `showAdaptiveSurface`：手机底部弹层，大屏对话框；
- 消息列表只允许垂直滚动；
- 不要给消息列表添加水平 `SingleChildScrollView`；
- 操作菜单使用 `showModalBottomSheet`，不占用侧边宽度。

## 7. 需要补充的本地化

当前 APK 已有：

- `copy_all_text`
- `message_edit`
- `edit_message`
- `delete`
- `cancel`
- `save`
- `retry`

建议新增：

- `message_actions`
- `select_text`
- `regenerate_reply`
- `delete_message_confirm`
- `regenerate_confirm`
- `remove_following_messages`
- `copy_reply_failed`

然后把 `AiMessageActionLabels` 从 `AppLocalizations` 传入。
