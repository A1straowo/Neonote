// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get note => '便签';

  @override
  String get label => '标签';

  @override
  String get motalk => 'MomoTalk';

  @override
  String get settings => '设置';

  @override
  String get general => '通用';

  @override
  String get language => '语言';

  @override
  String get dark_theme => '深色主题';

  @override
  String get the_quick_brown_fox_jumps_over_the_lazy_dog => '敏捷的棕色狐狸跳过懒狗身上';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get title => '标题';

  @override
  String get quit => '保存并退出吗';

  @override
  String get size => '缩放';

  @override
  String get normal => '默认';

  @override
  String get theme => '主题';

  @override
  String get color_scheme => '配色方案';

  @override
  String get default_color_scheme => '默认配色';

  @override
  String get optimize_storage => '优化存储';

  @override
  String get optimize_storage_subtitle => '清理无用媒体文件并压缩本地数据库';

  @override
  String get optimize_storage_confirm => '清理未引用的媒体文件、旧导出副本并压缩数据库？笔记内容会保留。';

  @override
  String optimize_storage_done(String size) {
    return '已释放 $size';
  }

  @override
  String get message_student => '学生';

  @override
  String get message_teacher => '老师';

  @override
  String get message => '消息';

  @override
  String get custom => '自定义';

  @override
  String get character => '学生';

  @override
  String get clear_failed => '清除失败!';

  @override
  String get clear_config => '清除配置';

  @override
  String get clear_cache => '清除缓存';

  @override
  String get auto_save => '自动保存';

  @override
  String get dialog => '对话框';

  @override
  String get font => '字体';

  @override
  String get radius => '圆角';

  @override
  String get settings_saved => '已保存当前设置';

  @override
  String get apply => '应用修改';

  @override
  String get restore_defaults => '恢复默认';

  @override
  String get restore_confirm => '确定要恢复所有设置为默认值吗？';

  @override
  String get defaults_restored => '已恢复默认数值';

  @override
  String get show_student_surname => '显示学生姓氏';

  @override
  String get reverse_name => '反转姓名';

  @override
  String get student_name_language => '学生名字语言';

  @override
  String get language_chinese => '中文';

  @override
  String get language_japanese => '日语';

  @override
  String get language_english => '英语';

  @override
  String get language_korean => '韩语';

  @override
  String get language_spanish => '西班牙语';

  @override
  String get language_russian => '俄语';

  @override
  String get remark => '备注';

  @override
  String get teacher_avatar => '老师头像';

  @override
  String get custom_student => '自定义学生';

  @override
  String get custom_greeting => '自定义问候语';

  @override
  String get interface => '界面';

  @override
  String get gesture => '手势';

  @override
  String get storage => '存储';

  @override
  String get about => '关于';

  @override
  String get archive_swipe => '存档（右滑）';

  @override
  String get delete_swipe => '删除（左滑）';

  @override
  String get select_student => '请选择学生';

  @override
  String get built_in => '内置';

  @override
  String get add_custom_student => '添加自定义学生';

  @override
  String get id => 'ID';

  @override
  String get student_name => '姓名';

  @override
  String get no_custom_students => '暂无自定义学生';

  @override
  String get delete => '删除';

  @override
  String get retry => '重试';

  @override
  String get component_text => '文本';

  @override
  String get component_checklist => '清单';

  @override
  String get component_drawing => '绘图';

  @override
  String get component_image => '图片';

  @override
  String get component_audio => '音频';

  @override
  String get component_delete => '删除组件';

  @override
  String component_added(String name) {
    return '已添加$name组件';
  }

  @override
  String get checklist_add_item => '添加待办项';

  @override
  String get clear => '清空';

  @override
  String get image_url => '图片链接';

  @override
  String get new_group => '新分组';

  @override
  String get new_chat => '新对话';

  @override
  String get group_create => '创建分组';

  @override
  String group_added(String name) {
    return '已添加分组“$name”';
  }

  @override
  String chat_added(String name) {
    return '已添加对话“$name”';
  }

  @override
  String group_delete_confirm(String name) {
    return '确定要删除分组“$name”及其全部对话吗？';
  }

  @override
  String chat_delete_confirm(String name) {
    return '确定要删除与“$name”的对话吗？';
  }

  @override
  String get input_name_hint => '输入名称…';

  @override
  String get name_required => '名称不能为空';

  @override
  String get add => '添加';

  @override
  String get rename => '重命名';

  @override
  String get default_group => '默认分组';

  @override
  String get no_chats_in_group => '暂无对话';

  @override
  String get no_messages => '暂无消息';

  @override
  String get message_hint => '输入消息…';

  @override
  String get send => '发送';

  @override
  String get tag_create => '创建新标签';

  @override
  String tag_added(String name) {
    return '已添加标签“$name”';
  }

  @override
  String get tag_rename => '重命名标签';

  @override
  String tag_delete_confirm(String name) {
    return '确定要删除标签“$name”吗？';
  }

  @override
  String get storage_used => '存储占用';

  @override
  String get cache_used => '缓存占用';

  @override
  String get calculating => '计算中';

  @override
  String get refresh => '刷新';

  @override
  String get clear_cache_confirm => '确定清除缓存吗？笔记内容不会被删除。';

  @override
  String get clear_config_confirm => '确定清除配置吗？所有个性化设置将恢复默认。';

  @override
  String get clear_success => '已清除';

  @override
  String get pick_from_gallery => '选择图片';

  @override
  String get image_pick_failed => '无法打开图库';

  @override
  String get edit_remark => '编辑备注';

  @override
  String get remark_hint => '输入备注';

  @override
  String get edit_greeting => '编辑问候语';

  @override
  String get greeting_hint => '输入问候语';

  @override
  String get recording => '录制中';

  @override
  String get record_audio => '录制音频';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get record_failed => '录制失败';

  @override
  String get mic_permission_denied => '需要麦克风权限';

  @override
  String get audio_unsupported => '当前平台不支持录音';

  @override
  String get add_image => '添加图片';

  @override
  String get take_photo => '拍照';

  @override
  String get content_hint => '记事';

  @override
  String get deepseek_harness => 'DeepSeek';

  @override
  String get deepseek_enable => '启用 AI';

  @override
  String get deepseek_api_key => 'API Key';

  @override
  String get deepseek_base_url => 'Base URL';

  @override
  String get deepseek_model => '模型';

  @override
  String get deepseek_system_prompt => '系统提示词';

  @override
  String get deepseek_test_connection => '测试连接';

  @override
  String get deepseek_testing => '测试中';

  @override
  String get deepseek_connected => '连接成功';

  @override
  String get deepseek_connection_failed => '连接失败';

  @override
  String get deepseek_not_configured => '请先配置 API Key';

  @override
  String get deepseek_saved => 'DeepSeek 设置已保存';

  @override
  String get ai_chat => 'DeepSeek';

  @override
  String get ai_assistant => 'DeepSeek';

  @override
  String get ai_input_hint => '向 AI 提问';

  @override
  String get ai_thinking => '思考中';

  @override
  String get ai_typing => '正在输入';

  @override
  String get ai_error => 'AI 出错';

  @override
  String get ai_insert_note => '插入到便签';

  @override
  String get ai_inserted_to_note => '已插入便签';

  @override
  String get ai_welcome => '有什么想问的都可以告诉我，也可以让我帮你写便签。';

  @override
  String get deepseek_disabled => 'AI 已禁用';

  @override
  String get ai_new_conversation_title => '新对话';

  @override
  String get ai_wait_reply => '请等待当前回复完成';

  @override
  String get ai_conversation_created => '已新建对话';

  @override
  String get ai_mode_minimal => '极简模式';

  @override
  String get ai_mode_standard => '标准模式';

  @override
  String get ai_reasoning_low => '推理：低';

  @override
  String get ai_reasoning_medium => '推理：中';

  @override
  String get ai_reasoning_high => '推理：高';

  @override
  String get close_image_preview => '关闭图片预览';

  @override
  String get close => '关闭';

  @override
  String get ai_image_added => '图片已添加，发送后将由 DeepSeek 识别';

  @override
  String get stop_recording => '停止录音';

  @override
  String get voice => '语音';

  @override
  String get ai_image_placeholder => '[图片]';

  @override
  String get ai_voice_placeholder => '[语音]';

  @override
  String get ai_voice_attached => '[用户附带语音]';

  @override
  String get ai_new_conversation => '新增对话';

  @override
  String get ai_history => '历史对话';

  @override
  String ai_voice_count(int count) {
    return '语音 $count';
  }

  @override
  String get ai_recognizing_image => 'DeepSeek 正在识图…';

  @override
  String get ai_empty_conversation => '空对话';

  @override
  String get ai_delete_conversation => '删除对话';

  @override
  String get ai_search_history => '搜索历史对话';

  @override
  String get ai_no_history => '暂无历史对话';

  @override
  String get ai_no_history_match => '没有匹配的对话';

  @override
  String get close_menu => '关闭菜单';

  @override
  String get note_blank_deleted => '空白便签已自动删除';

  @override
  String get note_discarded => '已舍弃并删除该便签';

  @override
  String get select_sentence_first => '请先选择一条语句';

  @override
  String get text_color => '文字颜色';

  @override
  String get current_sentence_only => '仅应用于当前语句';

  @override
  String get apply_label => '应用';

  @override
  String get choose_background => '选择背景';

  @override
  String get solid_background => '纯色背景';

  @override
  String get apply_solid_color => '应用纯色';

  @override
  String get no_background => '无背景';

  @override
  String get grid_background => '网格背景';

  @override
  String get square_grid => '正方形';

  @override
  String get dot_grid => '点状';

  @override
  String get horizontal_lines => '水平线';

  @override
  String get image_background => '图片背景';

  @override
  String get change_image => '更换图片';

  @override
  String get crop_again => '再次裁切';

  @override
  String get remove_image_background => '移除图片背景';

  @override
  String get background_image_missing => '背景图片不存在';

  @override
  String get cannot_read_background => '无法读取背景图片';

  @override
  String get crop_background => '裁切图片背景';

  @override
  String get crop_top => '上';

  @override
  String get crop_middle => '中';

  @override
  String get crop_bottom => '下';

  @override
  String get zoom => '缩放';

  @override
  String get crop_hint => '图片会自动铺满便签，裁切可调整重点区域。';

  @override
  String get use_original => '使用原图';

  @override
  String get finish_crop => '完成裁切';

  @override
  String crop_failed(String error) {
    return '裁切失败: $error';
  }

  @override
  String get checklist_item_hint => '清单项';

  @override
  String get insert_checklist_item => '插入清单项';

  @override
  String get insert_divider => '插入分隔线';

  @override
  String get insert_current_time => '插入当前时间';

  @override
  String get body_text => '正文';

  @override
  String get bold => '粗体';

  @override
  String get italic => '斜体';

  @override
  String get underline => '下划线';

  @override
  String get strikethrough => '删除线';

  @override
  String get align_left => '左对齐';

  @override
  String get align_center => '居中对齐';

  @override
  String get align_right => '右对齐';

  @override
  String get select_current_sentence => '全选当前句';

  @override
  String word_count(int count) {
    return '$count 字';
  }

  @override
  String get insert_content => '插入内容';

  @override
  String get text_format => '文字格式';

  @override
  String get more => '更多';

  @override
  String get select_tags => '选择标签';

  @override
  String get create_tag_first => '请先在标签页创建标签';

  @override
  String get delete_component_confirm => '确定删除这个便签组件吗？';

  @override
  String get no_text_content => '暂无文本内容';

  @override
  String get no_checklist_items => '暂无待办项';

  @override
  String completed_count(int done, int total) {
    return '$done / $total 已完成';
  }

  @override
  String get unnamed_checklist_item => '未命名待办项';

  @override
  String more_items(int count) {
    return '还有 $count 项';
  }

  @override
  String get no_drawings => '暂无绘图';

  @override
  String get no_images => '暂无图片';

  @override
  String get image_load_failed => '图片无法加载';

  @override
  String get no_recording => '暂无录音';

  @override
  String get recorded_tap_to_play => '已录制，点击进入后可播放';

  @override
  String get note_archive => '便签存档';

  @override
  String get no_archived_notes => '暂无存档便签';

  @override
  String get no_text_content_short => '无文本内容';

  @override
  String get restore => '恢复';

  @override
  String get momotalk_archive => 'MomoTalk 存档';

  @override
  String get no_archived_chats => '暂无存档对话';

  @override
  String get exit_unsaved_title => '当前内容尚未保存';

  @override
  String get exit_unsaved_message => '检测到未保存的修改，是否保存后退出？';

  @override
  String get discard => '舍弃';

  @override
  String get right_swipe_action => '右滑动作';

  @override
  String get left_swipe_action => '左滑动作';

  @override
  String get gesture_pin => '固定';

  @override
  String get gesture_archive => '存档';

  @override
  String get gesture_mark => '标记';

  @override
  String image_send_failed(String error) {
    return '图片发送失败: $error';
  }

  @override
  String get gallery_load_failed => '初始立绘差分加载失败';

  @override
  String get gallery_not_found => '未找到该学生的初始立绘差分';

  @override
  String get portrait_variants => '初始立绘差分';

  @override
  String get screenshot_failed => '截图失败';

  @override
  String get message_reorder => '换行';

  @override
  String get message_edit => '更改';

  @override
  String get message_transform => '转换';

  @override
  String get transform_developing => '转换功能开发中';

  @override
  String get edit_message => '更改消息';

  @override
  String get enter_new_message => '输入新的消息内容';

  @override
  String get not_enough_messages => '当前消息不足，无法调整位置';

  @override
  String get drag_to_reorder => '拖动消息调整位置';

  @override
  String get switch_student => '切换学生';

  @override
  String get emoji => '表情';

  @override
  String get image => '图片';

  @override
  String get student => '学生';

  @override
  String get send_as_student => '以学生身份发送';

  @override
  String get send_as_teacher => '以老师身份发送';

  @override
  String get screenshot => '截图';

  @override
  String get current_identity_student => '当前以学生身份发送';

  @override
  String get current_identity_teacher => '当前以老师身份发送';

  @override
  String get gallery => '相册';

  @override
  String get stroke_width => '笔画粗细';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get drawing_eraser => '橡皮擦';

  @override
  String get drawing_highlighter => '荧光笔';

  @override
  String get drawing_pencil => '铅笔';

  @override
  String get drawing_marker => '马克笔';

  @override
  String get version => '版本';

  @override
  String get developer => '开发者';

  @override
  String get open_source_license => '开源许可';

  @override
  String get clear_drawing_confirm => '确定清空当前绘图吗？';

  @override
  String get custom_color => '自定义颜色';

  @override
  String get search_students => '搜索学生';

  @override
  String get no_student_matches => '没有匹配的学生';

  @override
  String get ai_image_model_warning => '当前模型可能不支持图片识别，如需识图请切换到支持视觉的模型。';

  @override
  String get select_all_document => '全选全文';

  @override
  String get copy_all_text => '复制全文';

  @override
  String get all_text_copied => '全文已复制';

  @override
  String get move_canvas => '移动画布';

  @override
  String get center_canvas => '画布居中';

  @override
  String get zoom_in => '放大';

  @override
  String get zoom_out => '缩小';

  @override
  String get canvas_background => '画布背景';

  @override
  String get canvas_style_grid => '网格';

  @override
  String get canvas_style_dots => '点阵';

  @override
  String get canvas_style_none => '无背景';

  @override
  String ai_conversation_save_failed(String error) {
    return '对话保存失败：$error';
  }

  @override
  String get save_failed_retrying => '保存失败，修改已保留并将自动重试。';

  @override
  String get recovery_draft_found => '发现未保存草稿';

  @override
  String get recovery_draft_message => '检测到上次编辑留下的恢复草稿，是否恢复？';

  @override
  String get open_menu => '打开菜单';

  @override
  String get theme_system => '跟随系统';

  @override
  String get theme_light => '浅色';

  @override
  String get theme_dark => '深色';

  @override
  String get search_notes => '搜索便签';

  @override
  String get search_notes_hint => '搜索标题、内容和标签';

  @override
  String get search_empty_title => '输入关键词开始搜索';

  @override
  String get search_empty_message => '可搜索标题、正文、清单项和标签。';

  @override
  String get search_no_results_title => '没有匹配的便签';

  @override
  String get search_no_results_message => '请尝试更短的关键词或移除标签筛选。';

  @override
  String get search_clear => '清除搜索';

  @override
  String get untitled => '无标题';

  @override
  String search_results_count(int count) {
    return '$count 个结果';
  }

  @override
  String get copy_reply => '复制回复';

  @override
  String get regenerate_reply => '重新生成';

  @override
  String get reply_copied => '已复制回复';

  @override
  String get copy_reply_failed => '无法复制回复';

  @override
  String get export_markdown => '复制便签为 Markdown';

  @override
  String get export_markdown_subtitle => '复制所有活动便签到剪贴板';

  @override
  String get export_backup => '保存 JSON 备份';

  @override
  String get export_backup_subtitle => '保存便签、标签、聊天和 AI 对话';

  @override
  String get export_markdown_done => '便签已复制到剪贴板';

  @override
  String export_backup_saved(String path) {
    return '备份已保存至 $path';
  }

  @override
  String export_failed(String error) {
    return '导出失败：$error';
  }

  @override
  String get add_text_component => '添加文本组件';

  @override
  String get message_actions => '消息操作';

  @override
  String get copy => '复制';

  @override
  String get select_text => '选择文本';

  @override
  String get delete_message_confirm => '删除这条消息？';

  @override
  String get delete_message_body => '这条消息将从对话中移除。';

  @override
  String get regenerate_confirm => '重新生成这条回复？';

  @override
  String get remove_following_messages => '由于上下文会改变，这条回复之后的消息将被删除。';

  @override
  String get edit_message_hint => '编辑消息文本';

  @override
  String get about_tagline => '记录灵感、整理便签，与想法安静对话。';
}
