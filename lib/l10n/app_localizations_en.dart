// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get note => 'Note';

  @override
  String get label => 'Label';

  @override
  String get motalk => 'MomoTalk';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get language => 'Language';

  @override
  String get dark_theme => 'Dark theme';

  @override
  String get the_quick_brown_fox_jumps_over_the_lazy_dog => 'The quick brown fox jumps over the lazy dog';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get title => 'Title';

  @override
  String get quit => 'Save and quit?';

  @override
  String get size => 'Scale';

  @override
  String get normal => 'MD3E';

  @override
  String get theme => 'Theme';

  @override
  String get color_scheme => 'Color scheme';

  @override
  String get default_color_scheme => 'Default colors';

  @override
  String get optimize_storage => 'Optimize storage';

  @override
  String get optimize_storage_subtitle => 'Remove unused media and compact the local database';

  @override
  String get optimize_storage_confirm => 'Remove unreferenced media files, old export copies, and compact the database? Notes are kept.';

  @override
  String optimize_storage_done(String size) {
    return 'Released $size';
  }

  @override
  String get message_student => 'Student';

  @override
  String get message_teacher => 'Teacher';

  @override
  String get message => 'Message';

  @override
  String get custom => 'Custom';

  @override
  String get character => 'Student';

  @override
  String get clear_failed => 'Clear failed!';

  @override
  String get clear_config => 'Clear config';

  @override
  String get clear_cache => 'Clear cache';

  @override
  String get auto_save => 'Autosave';

  @override
  String get dialog => 'Dialog';

  @override
  String get font => 'Font';

  @override
  String get radius => 'Radius';

  @override
  String get settings_saved => 'Settings saved!';

  @override
  String get apply => 'Apply changes';

  @override
  String get restore_defaults => 'Restore defaults';

  @override
  String get restore_confirm => 'Restore all settings to default?';

  @override
  String get defaults_restored => 'Defaults restored';

  @override
  String get show_student_surname => 'Show student surname';

  @override
  String get reverse_name => 'Reverse name';

  @override
  String get student_name_language => 'Student name language';

  @override
  String get language_chinese => 'Chinese';

  @override
  String get language_japanese => 'Japanese';

  @override
  String get language_english => 'English';

  @override
  String get language_korean => 'Korean';

  @override
  String get language_spanish => 'Spanish';

  @override
  String get language_russian => 'Russian';

  @override
  String get remark => 'Remark';

  @override
  String get teacher_avatar => 'Teacher avatar';

  @override
  String get custom_student => 'Custom student';

  @override
  String get custom_greeting => 'Custom greeting';

  @override
  String get interface => 'Interface';

  @override
  String get gesture => 'Gesture';

  @override
  String get storage => 'Storage';

  @override
  String get about => 'About';

  @override
  String get archive_swipe => 'Archive (swipe right)';

  @override
  String get delete_swipe => 'Delete (swipe left)';

  @override
  String get select_student => 'Select student';

  @override
  String get built_in => 'Built-in';

  @override
  String get add_custom_student => 'Add custom student';

  @override
  String get id => 'ID';

  @override
  String get student_name => 'Name';

  @override
  String get no_custom_students => 'No custom students';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get component_text => 'Text';

  @override
  String get component_checklist => 'Checklist';

  @override
  String get component_drawing => 'Drawing';

  @override
  String get component_image => 'Image';

  @override
  String get component_audio => 'Audio';

  @override
  String get component_delete => 'Delete component';

  @override
  String component_added(String name) {
    return '$name component added';
  }

  @override
  String get checklist_add_item => 'Add an item';

  @override
  String get clear => 'Clear';

  @override
  String get image_url => 'Image URL';

  @override
  String get new_group => 'New group';

  @override
  String get new_chat => 'New chat';

  @override
  String get group_create => 'Create group';

  @override
  String group_added(String name) {
    return 'Group “$name” added';
  }

  @override
  String chat_added(String name) {
    return 'Chat “$name” added';
  }

  @override
  String group_delete_confirm(String name) {
    return 'Delete the group “$name” and all of its chats?';
  }

  @override
  String chat_delete_confirm(String name) {
    return 'Delete the chat with “$name”?';
  }

  @override
  String get input_name_hint => 'Enter a name…';

  @override
  String get name_required => 'The name cannot be empty';

  @override
  String get add => 'Add';

  @override
  String get rename => 'Rename';

  @override
  String get default_group => 'Default group';

  @override
  String get no_chats_in_group => 'No chats yet';

  @override
  String get no_messages => 'No messages yet';

  @override
  String get message_hint => 'Type a message…';

  @override
  String get send => 'Send';

  @override
  String get tag_create => 'Create new label';

  @override
  String tag_added(String name) {
    return 'Label “$name” added';
  }

  @override
  String get tag_rename => 'Rename label';

  @override
  String tag_delete_confirm(String name) {
    return 'Delete the label “$name”?';
  }

  @override
  String get storage_used => 'Storage used';

  @override
  String get cache_used => 'Cache used';

  @override
  String get calculating => 'Calculating';

  @override
  String get refresh => 'Refresh';

  @override
  String get clear_cache_confirm => 'Clear the cache? Your notes are kept.';

  @override
  String get clear_config_confirm => 'Clear the configuration? All preferences return to default.';

  @override
  String get clear_success => 'Cleared';

  @override
  String get pick_from_gallery => 'Choose from gallery';

  @override
  String get image_pick_failed => 'Could not open the gallery';

  @override
  String get edit_remark => 'Edit remark';

  @override
  String get remark_hint => 'Enter a remark';

  @override
  String get edit_greeting => 'Edit greeting';

  @override
  String get greeting_hint => 'Enter a greeting';

  @override
  String get recording => 'Recording';

  @override
  String get record_audio => 'Record audio';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get record_failed => 'Recording failed';

  @override
  String get mic_permission_denied => 'Microphone permission is required';

  @override
  String get audio_unsupported => 'Audio recording is not supported on this platform';

  @override
  String get add_image => 'Add image';

  @override
  String get take_photo => 'Take photo';

  @override
  String get content_hint => 'Note';

  @override
  String get deepseek_harness => 'DeepSeek';

  @override
  String get deepseek_enable => 'Enable AI';

  @override
  String get deepseek_api_key => 'API Key';

  @override
  String get deepseek_base_url => 'Base URL';

  @override
  String get deepseek_model => 'Model';

  @override
  String get deepseek_system_prompt => 'System prompt';

  @override
  String get deepseek_test_connection => 'Test connection';

  @override
  String get deepseek_testing => 'Testing';

  @override
  String get deepseek_connected => 'Connected';

  @override
  String get deepseek_connection_failed => 'Connection failed';

  @override
  String get deepseek_not_configured => 'Configure the API key first';

  @override
  String get deepseek_saved => 'DeepSeek settings saved';

  @override
  String get ai_chat => 'DeepSeek';

  @override
  String get ai_assistant => 'DeepSeek';

  @override
  String get ai_input_hint => 'Ask the AI';

  @override
  String get ai_thinking => 'Thinking';

  @override
  String get ai_typing => 'Typing';

  @override
  String get ai_error => 'AI error';

  @override
  String get ai_insert_note => 'Insert into notes';

  @override
  String get ai_inserted_to_note => 'Inserted into notes';

  @override
  String get ai_welcome => 'Ask me anything. I can also help you write notes.';

  @override
  String get deepseek_disabled => 'AI is disabled';

  @override
  String get ai_new_conversation_title => 'New conversation';

  @override
  String get ai_wait_reply => 'Please wait for the current response';

  @override
  String get ai_conversation_created => 'New conversation created';

  @override
  String get ai_mode_minimal => 'Minimal mode';

  @override
  String get ai_mode_standard => 'Standard mode';

  @override
  String get ai_reasoning_low => 'Reasoning: low';

  @override
  String get ai_reasoning_medium => 'Reasoning: medium';

  @override
  String get ai_reasoning_high => 'Reasoning: high';

  @override
  String get close_image_preview => 'Close image preview';

  @override
  String get close => 'Close';

  @override
  String get ai_image_added => 'Image added. DeepSeek will recognize it after sending.';

  @override
  String get stop_recording => 'Stop recording';

  @override
  String get voice => 'Voice';

  @override
  String get ai_image_placeholder => '[Image]';

  @override
  String get ai_voice_placeholder => '[Voice]';

  @override
  String get ai_voice_attached => '[User attached voice]';

  @override
  String get ai_new_conversation => 'New conversation';

  @override
  String get ai_history => 'History';

  @override
  String ai_voice_count(int count) {
    return 'Voice $count';
  }

  @override
  String get ai_recognizing_image => 'DeepSeek is recognizing the image…';

  @override
  String get ai_empty_conversation => 'Empty conversation';

  @override
  String get ai_delete_conversation => 'Delete conversation';

  @override
  String get ai_search_history => 'Search conversations';

  @override
  String get ai_no_history => 'No conversation history';

  @override
  String get ai_no_history_match => 'No matching conversations';

  @override
  String get close_menu => 'Close menu';

  @override
  String get note_blank_deleted => 'Blank note deleted automatically';

  @override
  String get note_discarded => 'Note discarded and deleted';

  @override
  String get select_sentence_first => 'Select a sentence first';

  @override
  String get text_color => 'Text color';

  @override
  String get current_sentence_only => 'Applies only to the current sentence';

  @override
  String get apply_label => 'Apply';

  @override
  String get choose_background => 'Choose background';

  @override
  String get solid_background => 'Solid color background';

  @override
  String get apply_solid_color => 'Apply color';

  @override
  String get no_background => 'No background';

  @override
  String get grid_background => 'Grid background';

  @override
  String get square_grid => 'Square';

  @override
  String get dot_grid => 'Dots';

  @override
  String get horizontal_lines => 'Horizontal lines';

  @override
  String get image_background => 'Image background';

  @override
  String get change_image => 'Change image';

  @override
  String get crop_again => 'Crop again';

  @override
  String get remove_image_background => 'Remove image background';

  @override
  String get background_image_missing => 'Background image not found';

  @override
  String get cannot_read_background => 'Could not read background image';

  @override
  String get crop_background => 'Crop image background';

  @override
  String get crop_top => 'Top';

  @override
  String get crop_middle => 'Middle';

  @override
  String get crop_bottom => 'Bottom';

  @override
  String get zoom => 'Zoom';

  @override
  String get crop_hint => 'The image fills the note automatically; crop to adjust the focal area.';

  @override
  String get use_original => 'Use original';

  @override
  String get finish_crop => 'Finish crop';

  @override
  String crop_failed(String error) {
    return 'Crop failed: $error';
  }

  @override
  String get checklist_item_hint => 'Checklist item';

  @override
  String get insert_checklist_item => 'Insert checklist item';

  @override
  String get insert_divider => 'Insert divider';

  @override
  String get insert_current_time => 'Insert current time';

  @override
  String get body_text => 'Body';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get underline => 'Underline';

  @override
  String get strikethrough => 'Strikethrough';

  @override
  String get align_left => 'Align left';

  @override
  String get align_center => 'Center';

  @override
  String get align_right => 'Align right';

  @override
  String get select_current_sentence => 'Select current sentence';

  @override
  String word_count(int count) {
    return '$count characters';
  }

  @override
  String get insert_content => 'Insert content';

  @override
  String get text_format => 'Text formatting';

  @override
  String get more => 'More';

  @override
  String get select_tags => 'Select labels';

  @override
  String get create_tag_first => 'Create a label on the Tags page first';

  @override
  String get delete_component_confirm => 'Delete this note component?';

  @override
  String get no_text_content => 'No text content';

  @override
  String get no_checklist_items => 'No checklist items';

  @override
  String completed_count(int done, int total) {
    return '$done / $total completed';
  }

  @override
  String get unnamed_checklist_item => 'Untitled checklist item';

  @override
  String more_items(int count) {
    return '$count more items';
  }

  @override
  String get no_drawings => 'No drawings';

  @override
  String get no_images => 'No images';

  @override
  String get image_load_failed => 'Could not load image';

  @override
  String get no_recording => 'No recording';

  @override
  String get recorded_tap_to_play => 'Recorded, tap to play';

  @override
  String get note_archive => 'Note archive';

  @override
  String get no_archived_notes => 'No archived notes';

  @override
  String get no_text_content_short => 'No text content';

  @override
  String get restore => 'Restore';

  @override
  String get momotalk_archive => 'MomoTalk archive';

  @override
  String get no_archived_chats => 'No archived chats';

  @override
  String get exit_unsaved_title => 'Unsaved changes';

  @override
  String get exit_unsaved_message => 'Unsaved changes were detected. Save before leaving?';

  @override
  String get discard => 'Discard';

  @override
  String get right_swipe_action => 'Right swipe action';

  @override
  String get left_swipe_action => 'Left swipe action';

  @override
  String get gesture_pin => 'Pin';

  @override
  String get gesture_archive => 'Archive';

  @override
  String get gesture_mark => 'Mark';

  @override
  String image_send_failed(String error) {
    return 'Image send failed: $error';
  }

  @override
  String get gallery_load_failed => 'Failed to load the portrait gallery';

  @override
  String get gallery_not_found => 'No portrait variants found for this student';

  @override
  String get portrait_variants => 'Portrait variants';

  @override
  String get screenshot_failed => 'Screenshot failed';

  @override
  String get message_reorder => 'Reorder';

  @override
  String get message_edit => 'Edit';

  @override
  String get message_transform => 'Transform';

  @override
  String get transform_developing => 'Transform is coming soon';

  @override
  String get edit_message => 'Edit message';

  @override
  String get enter_new_message => 'Enter the new message';

  @override
  String get not_enough_messages => 'Not enough messages to reorder';

  @override
  String get drag_to_reorder => 'Drag messages to reorder';

  @override
  String get switch_student => 'Switch student';

  @override
  String get emoji => 'Emoji';

  @override
  String get image => 'Image';

  @override
  String get student => 'Student';

  @override
  String get send_as_student => 'Send as student';

  @override
  String get send_as_teacher => 'Send as teacher';

  @override
  String get screenshot => 'Screenshot';

  @override
  String get current_identity_student => 'Now sending as student';

  @override
  String get current_identity_teacher => 'Now sending as teacher';

  @override
  String get gallery => 'Gallery';

  @override
  String get stroke_width => 'Stroke width';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get drawing_eraser => 'Eraser';

  @override
  String get drawing_highlighter => 'Highlighter';

  @override
  String get drawing_pencil => 'Pencil';

  @override
  String get drawing_marker => 'Marker';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get open_source_license => 'Open-source license';

  @override
  String get clear_drawing_confirm => 'Clear the drawing?';

  @override
  String get custom_color => 'Custom color';

  @override
  String get search_students => 'Search students';

  @override
  String get no_student_matches => 'No matching students';

  @override
  String get ai_image_model_warning => 'This model may not support image input. Switch to a vision-capable model to recognize images.';

  @override
  String get select_all_document => 'Select all text';

  @override
  String get copy_all_text => 'Copy all text';

  @override
  String get all_text_copied => 'All text copied';

  @override
  String get move_canvas => 'Move canvas';

  @override
  String get center_canvas => 'Center canvas';

  @override
  String get zoom_in => 'Zoom in';

  @override
  String get zoom_out => 'Zoom out';

  @override
  String get canvas_background => 'Canvas background';

  @override
  String get canvas_style_grid => 'Grid';

  @override
  String get canvas_style_dots => 'Dots';

  @override
  String get canvas_style_none => 'No background';

  @override
  String ai_conversation_save_failed(String error) {
    return 'Could not save the conversation: $error';
  }

  @override
  String get save_failed_retrying => 'Save failed. Your changes are kept and will be retried.';

  @override
  String get recovery_draft_found => 'Unsaved draft found';

  @override
  String get recovery_draft_message => 'A recovery draft from your last session is available. Restore it?';

  @override
  String get open_menu => 'Open menu';

  @override
  String get theme_system => 'System';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get search_notes => 'Search notes';

  @override
  String get search_notes_hint => 'Search titles, content and tags';

  @override
  String get search_empty_title => 'Start typing to search';

  @override
  String get search_empty_message => 'Search titles, body text, checklist items and tags.';

  @override
  String get search_no_results_title => 'No matching notes';

  @override
  String get search_no_results_message => 'Try a shorter keyword or remove a tag filter.';

  @override
  String get search_clear => 'Clear search';

  @override
  String get untitled => 'Untitled';

  @override
  String search_results_count(int count) {
    return '$count result(s)';
  }

  @override
  String get copy_reply => 'Copy reply';

  @override
  String get regenerate_reply => 'Regenerate';

  @override
  String get reply_copied => 'Reply copied';

  @override
  String get copy_reply_failed => 'Could not copy reply';

  @override
  String get export_markdown => 'Copy notes as Markdown';

  @override
  String get export_markdown_subtitle => 'Copy all active notes to the clipboard';

  @override
  String get export_backup => 'Save JSON backup';

  @override
  String get export_backup_subtitle => 'Save notes, tags, chats and AI conversations';

  @override
  String get export_markdown_done => 'Notes copied to clipboard';

  @override
  String export_backup_saved(String path) {
    return 'Backup saved to $path';
  }

  @override
  String export_failed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get add_text_component => 'Add text component';

  @override
  String get message_actions => 'Message actions';

  @override
  String get copy => 'Copy';

  @override
  String get select_text => 'Select text';

  @override
  String get delete_message_confirm => 'Delete this message?';

  @override
  String get delete_message_body => 'This message will be removed from the conversation.';

  @override
  String get regenerate_confirm => 'Regenerate this reply?';

  @override
  String get remove_following_messages => 'Messages after this reply will be removed because the context changes.';

  @override
  String get edit_message_hint => 'Edit message text';

  @override
  String get about_tagline => 'A quiet place for notes, ideas and conversations.';
}
