import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @motalk.
  ///
  /// In en, this message translates to:
  /// **'MomoTalk'**
  String get motalk;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get dark_theme;

  /// No description provided for @the_quick_brown_fox_jumps_over_the_lazy_dog.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog'**
  String get the_quick_brown_fox_jumps_over_the_lazy_dog;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Save and quit?'**
  String get quit;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get size;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'MD3E'**
  String get normal;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @color_scheme.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get color_scheme;

  /// No description provided for @default_color_scheme.
  ///
  /// In en, this message translates to:
  /// **'Default colors'**
  String get default_color_scheme;

  /// No description provided for @optimize_storage.
  ///
  /// In en, this message translates to:
  /// **'Optimize storage'**
  String get optimize_storage;

  /// No description provided for @optimize_storage_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove unused media and compact the local database'**
  String get optimize_storage_subtitle;

  /// No description provided for @optimize_storage_confirm.
  ///
  /// In en, this message translates to:
  /// **'Remove unreferenced media files, old export copies, and compact the database? Notes are kept.'**
  String get optimize_storage_confirm;

  /// No description provided for @optimize_storage_done.
  ///
  /// In en, this message translates to:
  /// **'Released {size}'**
  String optimize_storage_done(String size);

  /// No description provided for @message_student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get message_student;

  /// No description provided for @message_teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get message_teacher;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @character.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get character;

  /// No description provided for @clear_failed.
  ///
  /// In en, this message translates to:
  /// **'Clear failed!'**
  String get clear_failed;

  /// No description provided for @clear_config.
  ///
  /// In en, this message translates to:
  /// **'Clear config'**
  String get clear_config;

  /// No description provided for @clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clear_cache;

  /// No description provided for @auto_save.
  ///
  /// In en, this message translates to:
  /// **'Autosave'**
  String get auto_save;

  /// No description provided for @dialog.
  ///
  /// In en, this message translates to:
  /// **'Dialog'**
  String get dialog;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @radius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get radius;

  /// No description provided for @settings_saved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved!'**
  String get settings_saved;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply changes'**
  String get apply;

  /// No description provided for @restore_defaults.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get restore_defaults;

  /// No description provided for @restore_confirm.
  ///
  /// In en, this message translates to:
  /// **'Restore all settings to default?'**
  String get restore_confirm;

  /// No description provided for @defaults_restored.
  ///
  /// In en, this message translates to:
  /// **'Defaults restored'**
  String get defaults_restored;

  /// No description provided for @show_student_surname.
  ///
  /// In en, this message translates to:
  /// **'Show student surname'**
  String get show_student_surname;

  /// No description provided for @reverse_name.
  ///
  /// In en, this message translates to:
  /// **'Reverse name'**
  String get reverse_name;

  /// No description provided for @student_name_language.
  ///
  /// In en, this message translates to:
  /// **'Student name language'**
  String get student_name_language;

  /// No description provided for @language_chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get language_chinese;

  /// No description provided for @language_japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get language_japanese;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get language_korean;

  /// No description provided for @language_spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get language_spanish;

  /// No description provided for @language_russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get language_russian;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Remark'**
  String get remark;

  /// No description provided for @teacher_avatar.
  ///
  /// In en, this message translates to:
  /// **'Teacher avatar'**
  String get teacher_avatar;

  /// No description provided for @custom_student.
  ///
  /// In en, this message translates to:
  /// **'Custom student'**
  String get custom_student;

  /// No description provided for @custom_greeting.
  ///
  /// In en, this message translates to:
  /// **'Custom greeting'**
  String get custom_greeting;

  /// No description provided for @interface.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// No description provided for @gesture.
  ///
  /// In en, this message translates to:
  /// **'Gesture'**
  String get gesture;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @archive_swipe.
  ///
  /// In en, this message translates to:
  /// **'Archive (swipe right)'**
  String get archive_swipe;

  /// No description provided for @delete_swipe.
  ///
  /// In en, this message translates to:
  /// **'Delete (swipe left)'**
  String get delete_swipe;

  /// No description provided for @select_student.
  ///
  /// In en, this message translates to:
  /// **'Select student'**
  String get select_student;

  /// No description provided for @built_in.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get built_in;

  /// No description provided for @add_custom_student.
  ///
  /// In en, this message translates to:
  /// **'Add custom student'**
  String get add_custom_student;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @student_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get student_name;

  /// No description provided for @no_custom_students.
  ///
  /// In en, this message translates to:
  /// **'No custom students'**
  String get no_custom_students;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @component_text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get component_text;

  /// No description provided for @component_checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get component_checklist;

  /// No description provided for @component_drawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get component_drawing;

  /// No description provided for @component_image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get component_image;

  /// No description provided for @component_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get component_audio;

  /// No description provided for @component_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete component'**
  String get component_delete;

  /// snackbar after a component was added
  ///
  /// In en, this message translates to:
  /// **'{name} component added'**
  String component_added(String name);

  /// No description provided for @checklist_add_item.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get checklist_add_item;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @image_url.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get image_url;

  /// No description provided for @new_group.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get new_group;

  /// No description provided for @new_chat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get new_chat;

  /// No description provided for @group_create.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get group_create;

  /// snackbar after a group was added
  ///
  /// In en, this message translates to:
  /// **'Group “{name}” added'**
  String group_added(String name);

  /// snackbar after a chat was added
  ///
  /// In en, this message translates to:
  /// **'Chat “{name}” added'**
  String chat_added(String name);

  /// delete group confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete the group “{name}” and all of its chats?'**
  String group_delete_confirm(String name);

  /// delete chat confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete the chat with “{name}”?'**
  String chat_delete_confirm(String name);

  /// No description provided for @input_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name…'**
  String get input_name_hint;

  /// No description provided for @name_required.
  ///
  /// In en, this message translates to:
  /// **'The name cannot be empty'**
  String get name_required;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @default_group.
  ///
  /// In en, this message translates to:
  /// **'Default group'**
  String get default_group;

  /// No description provided for @no_chats_in_group.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get no_chats_in_group;

  /// No description provided for @no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get no_messages;

  /// No description provided for @message_hint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get message_hint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @tag_create.
  ///
  /// In en, this message translates to:
  /// **'Create new label'**
  String get tag_create;

  /// snackbar after a label was added
  ///
  /// In en, this message translates to:
  /// **'Label “{name}” added'**
  String tag_added(String name);

  /// No description provided for @tag_rename.
  ///
  /// In en, this message translates to:
  /// **'Rename label'**
  String get tag_rename;

  /// delete label confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete the label “{name}”?'**
  String tag_delete_confirm(String name);

  /// No description provided for @storage_used.
  ///
  /// In en, this message translates to:
  /// **'Storage used'**
  String get storage_used;

  /// No description provided for @cache_used.
  ///
  /// In en, this message translates to:
  /// **'Cache used'**
  String get cache_used;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating'**
  String get calculating;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @clear_cache_confirm.
  ///
  /// In en, this message translates to:
  /// **'Clear the cache? Your notes are kept.'**
  String get clear_cache_confirm;

  /// No description provided for @clear_config_confirm.
  ///
  /// In en, this message translates to:
  /// **'Clear the configuration? All preferences return to default.'**
  String get clear_config_confirm;

  /// No description provided for @clear_success.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get clear_success;

  /// No description provided for @pick_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get pick_from_gallery;

  /// No description provided for @image_pick_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the gallery'**
  String get image_pick_failed;

  /// No description provided for @edit_remark.
  ///
  /// In en, this message translates to:
  /// **'Edit remark'**
  String get edit_remark;

  /// No description provided for @remark_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a remark'**
  String get remark_hint;

  /// No description provided for @edit_greeting.
  ///
  /// In en, this message translates to:
  /// **'Edit greeting'**
  String get edit_greeting;

  /// No description provided for @greeting_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a greeting'**
  String get greeting_hint;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @record_audio.
  ///
  /// In en, this message translates to:
  /// **'Record audio'**
  String get record_audio;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @record_failed.
  ///
  /// In en, this message translates to:
  /// **'Recording failed'**
  String get record_failed;

  /// No description provided for @mic_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required'**
  String get mic_permission_denied;

  /// No description provided for @audio_unsupported.
  ///
  /// In en, this message translates to:
  /// **'Audio recording is not supported on this platform'**
  String get audio_unsupported;

  /// No description provided for @add_image.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get add_image;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get take_photo;

  /// No description provided for @content_hint.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get content_hint;

  /// No description provided for @deepseek_harness.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek'**
  String get deepseek_harness;

  /// No description provided for @deepseek_enable.
  ///
  /// In en, this message translates to:
  /// **'Enable AI'**
  String get deepseek_enable;

  /// No description provided for @deepseek_api_key.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get deepseek_api_key;

  /// No description provided for @deepseek_base_url.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get deepseek_base_url;

  /// No description provided for @deepseek_model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get deepseek_model;

  /// No description provided for @deepseek_system_prompt.
  ///
  /// In en, this message translates to:
  /// **'System prompt'**
  String get deepseek_system_prompt;

  /// No description provided for @deepseek_test_connection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get deepseek_test_connection;

  /// No description provided for @deepseek_testing.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get deepseek_testing;

  /// No description provided for @deepseek_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get deepseek_connected;

  /// No description provided for @deepseek_connection_failed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get deepseek_connection_failed;

  /// No description provided for @deepseek_not_configured.
  ///
  /// In en, this message translates to:
  /// **'Configure the API key first'**
  String get deepseek_not_configured;

  /// No description provided for @deepseek_saved.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek settings saved'**
  String get deepseek_saved;

  /// No description provided for @ai_chat.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek'**
  String get ai_chat;

  /// No description provided for @ai_assistant.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek'**
  String get ai_assistant;

  /// No description provided for @ai_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Ask the AI'**
  String get ai_input_hint;

  /// No description provided for @ai_thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get ai_thinking;

  /// No description provided for @ai_typing.
  ///
  /// In en, this message translates to:
  /// **'Typing'**
  String get ai_typing;

  /// No description provided for @ai_error.
  ///
  /// In en, this message translates to:
  /// **'AI error'**
  String get ai_error;

  /// No description provided for @ai_insert_note.
  ///
  /// In en, this message translates to:
  /// **'Insert into notes'**
  String get ai_insert_note;

  /// No description provided for @ai_inserted_to_note.
  ///
  /// In en, this message translates to:
  /// **'Inserted into notes'**
  String get ai_inserted_to_note;

  /// No description provided for @ai_welcome.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything. I can also help you write notes.'**
  String get ai_welcome;

  /// No description provided for @deepseek_disabled.
  ///
  /// In en, this message translates to:
  /// **'AI is disabled'**
  String get deepseek_disabled;

  /// No description provided for @ai_new_conversation_title.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get ai_new_conversation_title;

  /// No description provided for @ai_wait_reply.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the current response'**
  String get ai_wait_reply;

  /// No description provided for @ai_conversation_created.
  ///
  /// In en, this message translates to:
  /// **'New conversation created'**
  String get ai_conversation_created;

  /// No description provided for @ai_mode_minimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal mode'**
  String get ai_mode_minimal;

  /// No description provided for @ai_mode_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard mode'**
  String get ai_mode_standard;

  /// No description provided for @ai_reasoning_low.
  ///
  /// In en, this message translates to:
  /// **'Reasoning: low'**
  String get ai_reasoning_low;

  /// No description provided for @ai_reasoning_medium.
  ///
  /// In en, this message translates to:
  /// **'Reasoning: medium'**
  String get ai_reasoning_medium;

  /// No description provided for @ai_reasoning_high.
  ///
  /// In en, this message translates to:
  /// **'Reasoning: high'**
  String get ai_reasoning_high;

  /// No description provided for @close_image_preview.
  ///
  /// In en, this message translates to:
  /// **'Close image preview'**
  String get close_image_preview;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ai_image_added.
  ///
  /// In en, this message translates to:
  /// **'Image added. DeepSeek will recognize it after sending.'**
  String get ai_image_added;

  /// No description provided for @stop_recording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stop_recording;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @ai_image_placeholder.
  ///
  /// In en, this message translates to:
  /// **'[Image]'**
  String get ai_image_placeholder;

  /// No description provided for @ai_voice_placeholder.
  ///
  /// In en, this message translates to:
  /// **'[Voice]'**
  String get ai_voice_placeholder;

  /// No description provided for @ai_voice_attached.
  ///
  /// In en, this message translates to:
  /// **'[User attached voice]'**
  String get ai_voice_attached;

  /// No description provided for @ai_new_conversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get ai_new_conversation;

  /// No description provided for @ai_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get ai_history;

  /// Number of voice attachments
  ///
  /// In en, this message translates to:
  /// **'Voice {count}'**
  String ai_voice_count(int count);

  /// No description provided for @ai_recognizing_image.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek is recognizing the image…'**
  String get ai_recognizing_image;

  /// No description provided for @ai_empty_conversation.
  ///
  /// In en, this message translates to:
  /// **'Empty conversation'**
  String get ai_empty_conversation;

  /// No description provided for @ai_delete_conversation.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get ai_delete_conversation;

  /// No description provided for @ai_search_history.
  ///
  /// In en, this message translates to:
  /// **'Search conversations'**
  String get ai_search_history;

  /// No description provided for @ai_no_history.
  ///
  /// In en, this message translates to:
  /// **'No conversation history'**
  String get ai_no_history;

  /// No description provided for @ai_no_history_match.
  ///
  /// In en, this message translates to:
  /// **'No matching conversations'**
  String get ai_no_history_match;

  /// No description provided for @close_menu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get close_menu;

  /// No description provided for @note_blank_deleted.
  ///
  /// In en, this message translates to:
  /// **'Blank note deleted automatically'**
  String get note_blank_deleted;

  /// No description provided for @note_discarded.
  ///
  /// In en, this message translates to:
  /// **'Note discarded and deleted'**
  String get note_discarded;

  /// No description provided for @select_sentence_first.
  ///
  /// In en, this message translates to:
  /// **'Select a sentence first'**
  String get select_sentence_first;

  /// No description provided for @text_color.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get text_color;

  /// No description provided for @current_sentence_only.
  ///
  /// In en, this message translates to:
  /// **'Applies only to the current sentence'**
  String get current_sentence_only;

  /// No description provided for @apply_label.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply_label;

  /// No description provided for @choose_background.
  ///
  /// In en, this message translates to:
  /// **'Choose background'**
  String get choose_background;

  /// No description provided for @solid_background.
  ///
  /// In en, this message translates to:
  /// **'Solid color background'**
  String get solid_background;

  /// No description provided for @apply_solid_color.
  ///
  /// In en, this message translates to:
  /// **'Apply color'**
  String get apply_solid_color;

  /// No description provided for @no_background.
  ///
  /// In en, this message translates to:
  /// **'No background'**
  String get no_background;

  /// No description provided for @grid_background.
  ///
  /// In en, this message translates to:
  /// **'Grid background'**
  String get grid_background;

  /// No description provided for @square_grid.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get square_grid;

  /// No description provided for @dot_grid.
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get dot_grid;

  /// No description provided for @horizontal_lines.
  ///
  /// In en, this message translates to:
  /// **'Horizontal lines'**
  String get horizontal_lines;

  /// No description provided for @image_background.
  ///
  /// In en, this message translates to:
  /// **'Image background'**
  String get image_background;

  /// No description provided for @change_image.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get change_image;

  /// No description provided for @crop_again.
  ///
  /// In en, this message translates to:
  /// **'Crop again'**
  String get crop_again;

  /// No description provided for @remove_image_background.
  ///
  /// In en, this message translates to:
  /// **'Remove image background'**
  String get remove_image_background;

  /// No description provided for @background_image_missing.
  ///
  /// In en, this message translates to:
  /// **'Background image not found'**
  String get background_image_missing;

  /// No description provided for @cannot_read_background.
  ///
  /// In en, this message translates to:
  /// **'Could not read background image'**
  String get cannot_read_background;

  /// No description provided for @crop_background.
  ///
  /// In en, this message translates to:
  /// **'Crop image background'**
  String get crop_background;

  /// No description provided for @crop_top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get crop_top;

  /// No description provided for @crop_middle.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get crop_middle;

  /// No description provided for @crop_bottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get crop_bottom;

  /// No description provided for @zoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get zoom;

  /// No description provided for @crop_hint.
  ///
  /// In en, this message translates to:
  /// **'The image fills the note automatically; crop to adjust the focal area.'**
  String get crop_hint;

  /// No description provided for @use_original.
  ///
  /// In en, this message translates to:
  /// **'Use original'**
  String get use_original;

  /// No description provided for @finish_crop.
  ///
  /// In en, this message translates to:
  /// **'Finish crop'**
  String get finish_crop;

  /// No description provided for @crop_failed.
  ///
  /// In en, this message translates to:
  /// **'Crop failed: {error}'**
  String crop_failed(String error);

  /// No description provided for @checklist_item_hint.
  ///
  /// In en, this message translates to:
  /// **'Checklist item'**
  String get checklist_item_hint;

  /// No description provided for @insert_checklist_item.
  ///
  /// In en, this message translates to:
  /// **'Insert checklist item'**
  String get insert_checklist_item;

  /// No description provided for @insert_divider.
  ///
  /// In en, this message translates to:
  /// **'Insert divider'**
  String get insert_divider;

  /// No description provided for @insert_current_time.
  ///
  /// In en, this message translates to:
  /// **'Insert current time'**
  String get insert_current_time;

  /// No description provided for @body_text.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body_text;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @underline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// No description provided for @strikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get strikethrough;

  /// No description provided for @align_left.
  ///
  /// In en, this message translates to:
  /// **'Align left'**
  String get align_left;

  /// No description provided for @align_center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get align_center;

  /// No description provided for @align_right.
  ///
  /// In en, this message translates to:
  /// **'Align right'**
  String get align_right;

  /// No description provided for @select_current_sentence.
  ///
  /// In en, this message translates to:
  /// **'Select current sentence'**
  String get select_current_sentence;

  /// No description provided for @word_count.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String word_count(int count);

  /// No description provided for @insert_content.
  ///
  /// In en, this message translates to:
  /// **'Insert content'**
  String get insert_content;

  /// No description provided for @text_format.
  ///
  /// In en, this message translates to:
  /// **'Text formatting'**
  String get text_format;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @select_tags.
  ///
  /// In en, this message translates to:
  /// **'Select labels'**
  String get select_tags;

  /// No description provided for @create_tag_first.
  ///
  /// In en, this message translates to:
  /// **'Create a label on the Tags page first'**
  String get create_tag_first;

  /// No description provided for @delete_component_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this note component?'**
  String get delete_component_confirm;

  /// No description provided for @no_text_content.
  ///
  /// In en, this message translates to:
  /// **'No text content'**
  String get no_text_content;

  /// No description provided for @no_checklist_items.
  ///
  /// In en, this message translates to:
  /// **'No checklist items'**
  String get no_checklist_items;

  /// No description provided for @completed_count.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} completed'**
  String completed_count(int done, int total);

  /// No description provided for @unnamed_checklist_item.
  ///
  /// In en, this message translates to:
  /// **'Untitled checklist item'**
  String get unnamed_checklist_item;

  /// No description provided for @more_items.
  ///
  /// In en, this message translates to:
  /// **'{count} more items'**
  String more_items(int count);

  /// No description provided for @no_drawings.
  ///
  /// In en, this message translates to:
  /// **'No drawings'**
  String get no_drawings;

  /// No description provided for @no_images.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get no_images;

  /// No description provided for @image_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load image'**
  String get image_load_failed;

  /// No description provided for @no_recording.
  ///
  /// In en, this message translates to:
  /// **'No recording'**
  String get no_recording;

  /// No description provided for @recorded_tap_to_play.
  ///
  /// In en, this message translates to:
  /// **'Recorded, tap to play'**
  String get recorded_tap_to_play;

  /// No description provided for @note_archive.
  ///
  /// In en, this message translates to:
  /// **'Note archive'**
  String get note_archive;

  /// No description provided for @no_archived_notes.
  ///
  /// In en, this message translates to:
  /// **'No archived notes'**
  String get no_archived_notes;

  /// No description provided for @no_text_content_short.
  ///
  /// In en, this message translates to:
  /// **'No text content'**
  String get no_text_content_short;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @momotalk_archive.
  ///
  /// In en, this message translates to:
  /// **'MomoTalk archive'**
  String get momotalk_archive;

  /// No description provided for @no_archived_chats.
  ///
  /// In en, this message translates to:
  /// **'No archived chats'**
  String get no_archived_chats;

  /// No description provided for @exit_unsaved_title.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get exit_unsaved_title;

  /// No description provided for @exit_unsaved_message.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes were detected. Save before leaving?'**
  String get exit_unsaved_message;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @right_swipe_action.
  ///
  /// In en, this message translates to:
  /// **'Right swipe action'**
  String get right_swipe_action;

  /// No description provided for @left_swipe_action.
  ///
  /// In en, this message translates to:
  /// **'Left swipe action'**
  String get left_swipe_action;

  /// No description provided for @gesture_pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get gesture_pin;

  /// No description provided for @gesture_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get gesture_archive;

  /// No description provided for @gesture_mark.
  ///
  /// In en, this message translates to:
  /// **'Mark'**
  String get gesture_mark;

  /// No description provided for @image_send_failed.
  ///
  /// In en, this message translates to:
  /// **'Image send failed: {error}'**
  String image_send_failed(String error);

  /// No description provided for @gallery_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the portrait gallery'**
  String get gallery_load_failed;

  /// No description provided for @gallery_not_found.
  ///
  /// In en, this message translates to:
  /// **'No portrait variants found for this student'**
  String get gallery_not_found;

  /// No description provided for @portrait_variants.
  ///
  /// In en, this message translates to:
  /// **'Portrait variants'**
  String get portrait_variants;

  /// No description provided for @screenshot_failed.
  ///
  /// In en, this message translates to:
  /// **'Screenshot failed'**
  String get screenshot_failed;

  /// No description provided for @message_reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get message_reorder;

  /// No description provided for @message_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get message_edit;

  /// No description provided for @message_transform.
  ///
  /// In en, this message translates to:
  /// **'Transform'**
  String get message_transform;

  /// No description provided for @transform_developing.
  ///
  /// In en, this message translates to:
  /// **'Transform is coming soon'**
  String get transform_developing;

  /// No description provided for @edit_message.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get edit_message;

  /// No description provided for @enter_new_message.
  ///
  /// In en, this message translates to:
  /// **'Enter the new message'**
  String get enter_new_message;

  /// No description provided for @not_enough_messages.
  ///
  /// In en, this message translates to:
  /// **'Not enough messages to reorder'**
  String get not_enough_messages;

  /// No description provided for @drag_to_reorder.
  ///
  /// In en, this message translates to:
  /// **'Drag messages to reorder'**
  String get drag_to_reorder;

  /// No description provided for @switch_student.
  ///
  /// In en, this message translates to:
  /// **'Switch student'**
  String get switch_student;

  /// No description provided for @emoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get emoji;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @send_as_student.
  ///
  /// In en, this message translates to:
  /// **'Send as student'**
  String get send_as_student;

  /// No description provided for @send_as_teacher.
  ///
  /// In en, this message translates to:
  /// **'Send as teacher'**
  String get send_as_teacher;

  /// No description provided for @screenshot.
  ///
  /// In en, this message translates to:
  /// **'Screenshot'**
  String get screenshot;

  /// No description provided for @current_identity_student.
  ///
  /// In en, this message translates to:
  /// **'Now sending as student'**
  String get current_identity_student;

  /// No description provided for @current_identity_teacher.
  ///
  /// In en, this message translates to:
  /// **'Now sending as teacher'**
  String get current_identity_teacher;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @stroke_width.
  ///
  /// In en, this message translates to:
  /// **'Stroke width'**
  String get stroke_width;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @drawing_eraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get drawing_eraser;

  /// No description provided for @drawing_highlighter.
  ///
  /// In en, this message translates to:
  /// **'Highlighter'**
  String get drawing_highlighter;

  /// No description provided for @drawing_pencil.
  ///
  /// In en, this message translates to:
  /// **'Pencil'**
  String get drawing_pencil;

  /// No description provided for @drawing_marker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get drawing_marker;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @open_source_license.
  ///
  /// In en, this message translates to:
  /// **'Open-source license'**
  String get open_source_license;

  /// No description provided for @clear_drawing_confirm.
  ///
  /// In en, this message translates to:
  /// **'Clear the drawing?'**
  String get clear_drawing_confirm;

  /// No description provided for @custom_color.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get custom_color;

  /// No description provided for @search_students.
  ///
  /// In en, this message translates to:
  /// **'Search students'**
  String get search_students;

  /// No description provided for @no_student_matches.
  ///
  /// In en, this message translates to:
  /// **'No matching students'**
  String get no_student_matches;

  /// No description provided for @ai_image_model_warning.
  ///
  /// In en, this message translates to:
  /// **'This model may not support image input. Switch to a vision-capable model to recognize images.'**
  String get ai_image_model_warning;

  /// No description provided for @select_all_document.
  ///
  /// In en, this message translates to:
  /// **'Select all text'**
  String get select_all_document;

  /// No description provided for @copy_all_text.
  ///
  /// In en, this message translates to:
  /// **'Copy all text'**
  String get copy_all_text;

  /// No description provided for @all_text_copied.
  ///
  /// In en, this message translates to:
  /// **'All text copied'**
  String get all_text_copied;

  /// No description provided for @move_canvas.
  ///
  /// In en, this message translates to:
  /// **'Move canvas'**
  String get move_canvas;

  /// No description provided for @center_canvas.
  ///
  /// In en, this message translates to:
  /// **'Center canvas'**
  String get center_canvas;

  /// No description provided for @zoom_in.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoom_in;

  /// No description provided for @zoom_out.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoom_out;

  /// No description provided for @canvas_background.
  ///
  /// In en, this message translates to:
  /// **'Canvas background'**
  String get canvas_background;

  /// No description provided for @canvas_style_grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get canvas_style_grid;

  /// No description provided for @canvas_style_dots.
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get canvas_style_dots;

  /// No description provided for @canvas_style_none.
  ///
  /// In en, this message translates to:
  /// **'No background'**
  String get canvas_style_none;

  /// No description provided for @ai_conversation_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the conversation: {error}'**
  String ai_conversation_save_failed(String error);

  /// No description provided for @save_failed_retrying.
  ///
  /// In en, this message translates to:
  /// **'Save failed. Your changes are kept and will be retried.'**
  String get save_failed_retrying;

  /// No description provided for @recovery_draft_found.
  ///
  /// In en, this message translates to:
  /// **'Unsaved draft found'**
  String get recovery_draft_found;

  /// No description provided for @recovery_draft_message.
  ///
  /// In en, this message translates to:
  /// **'A recovery draft from your last session is available. Restore it?'**
  String get recovery_draft_message;

  /// No description provided for @open_menu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get open_menu;

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @search_notes.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get search_notes;

  /// No description provided for @search_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Search titles, content and tags'**
  String get search_notes_hint;

  /// No description provided for @search_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get search_empty_title;

  /// No description provided for @search_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Search titles, body text, checklist items and tags.'**
  String get search_empty_message;

  /// No description provided for @search_no_results_title.
  ///
  /// In en, this message translates to:
  /// **'No matching notes'**
  String get search_no_results_title;

  /// No description provided for @search_no_results_message.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter keyword or remove a tag filter.'**
  String get search_no_results_message;

  /// No description provided for @search_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get search_clear;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @search_results_count.
  ///
  /// In en, this message translates to:
  /// **'{count} result(s)'**
  String search_results_count(int count);

  /// No description provided for @copy_reply.
  ///
  /// In en, this message translates to:
  /// **'Copy reply'**
  String get copy_reply;

  /// No description provided for @regenerate_reply.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate_reply;

  /// No description provided for @reply_copied.
  ///
  /// In en, this message translates to:
  /// **'Reply copied'**
  String get reply_copied;

  /// No description provided for @copy_reply_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not copy reply'**
  String get copy_reply_failed;

  /// No description provided for @export_markdown.
  ///
  /// In en, this message translates to:
  /// **'Copy notes as Markdown'**
  String get export_markdown;

  /// No description provided for @export_markdown_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy all active notes to the clipboard'**
  String get export_markdown_subtitle;

  /// No description provided for @export_backup.
  ///
  /// In en, this message translates to:
  /// **'Save JSON backup'**
  String get export_backup;

  /// No description provided for @export_backup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Save notes, tags, chats and AI conversations'**
  String get export_backup_subtitle;

  /// No description provided for @export_markdown_done.
  ///
  /// In en, this message translates to:
  /// **'Notes copied to clipboard'**
  String get export_markdown_done;

  /// No description provided for @export_backup_saved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to {path}'**
  String export_backup_saved(String path);

  /// No description provided for @export_failed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String export_failed(String error);

  /// No description provided for @add_text_component.
  ///
  /// In en, this message translates to:
  /// **'Add text component'**
  String get add_text_component;

  /// No description provided for @message_actions.
  ///
  /// In en, this message translates to:
  /// **'Message actions'**
  String get message_actions;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @select_text.
  ///
  /// In en, this message translates to:
  /// **'Select text'**
  String get select_text;

  /// No description provided for @delete_message_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get delete_message_confirm;

  /// No description provided for @delete_message_body.
  ///
  /// In en, this message translates to:
  /// **'This message will be removed from the conversation.'**
  String get delete_message_body;

  /// No description provided for @regenerate_confirm.
  ///
  /// In en, this message translates to:
  /// **'Regenerate this reply?'**
  String get regenerate_confirm;

  /// No description provided for @remove_following_messages.
  ///
  /// In en, this message translates to:
  /// **'Messages after this reply will be removed because the context changes.'**
  String get remove_following_messages;

  /// No description provided for @edit_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Edit message text'**
  String get edit_message_hint;

  /// No description provided for @about_tagline.
  ///
  /// In en, this message translates to:
  /// **'A quiet place for notes, ideas and conversations.'**
  String get about_tagline;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'ja', 'ko', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'ru': return AppLocalizationsRu();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
