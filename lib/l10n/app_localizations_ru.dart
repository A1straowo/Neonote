// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get note => 'Заметка';

  @override
  String get label => 'Метка';

  @override
  String get motalk => 'MomoTalk';

  @override
  String get settings => 'Настройки';

  @override
  String get general => 'Общие';

  @override
  String get language => 'Язык';

  @override
  String get dark_theme => 'Тёмная тема';

  @override
  String get the_quick_brown_fox_jumps_over_the_lazy_dog => 'Быстрая коричневая лиса прыгает через ленивую собаку';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get title => 'Заголовок';

  @override
  String get quit => 'Сохранить и выйти?';

  @override
  String get size => 'Масштаб';

  @override
  String get normal => 'По умолчанию';

  @override
  String get theme => 'Тема';

  @override
  String get color_scheme => 'Цветовая схема';

  @override
  String get default_color_scheme => 'Цвета по умолчанию';

  @override
  String get optimize_storage => 'Оптимизировать хранилище';

  @override
  String get optimize_storage_subtitle => 'Удалить неиспользуемые медиафайлы и сжать локальную базу данных';

  @override
  String get optimize_storage_confirm => 'Удалить неиспользуемые медиафайлы, старые копии экспорта и сжать базу данных? Заметки останутся.';

  @override
  String optimize_storage_done(String size) {
    return 'Освобождено $size';
  }

  @override
  String get message_student => 'Студент';

  @override
  String get message_teacher => 'Учитель';

  @override
  String get message => 'Сообщение';

  @override
  String get custom => 'Пользовательский';

  @override
  String get character => 'Студент';

  @override
  String get clear_failed => 'Ошибка очистки!';

  @override
  String get clear_config => 'Очистить настройки';

  @override
  String get clear_cache => 'Очистить кэш';

  @override
  String get auto_save => 'Автосохранение';

  @override
  String get dialog => 'Диалог';

  @override
  String get font => 'Шрифт';

  @override
  String get radius => 'Радиус';

  @override
  String get settings_saved => 'Настройки сохранены!';

  @override
  String get apply => 'Применить';

  @override
  String get restore_defaults => 'Восстановить значения по умолчанию';

  @override
  String get restore_confirm => 'Восстановить все настройки по умолчанию?';

  @override
  String get defaults_restored => 'Значения по умолчанию восстановлены';

  @override
  String get show_student_surname => 'Показывать фамилию';

  @override
  String get reverse_name => 'Изменить порядок имени';

  @override
  String get student_name_language => 'Язык имени студента';

  @override
  String get language_chinese => 'Китайский';

  @override
  String get language_japanese => 'Японский';

  @override
  String get language_english => 'Английский';

  @override
  String get language_korean => 'Корейский';

  @override
  String get language_spanish => 'Испанский';

  @override
  String get language_russian => 'Русский';

  @override
  String get remark => 'Примечание';

  @override
  String get teacher_avatar => 'Аватар учителя';

  @override
  String get custom_student => 'Пользовательский студент';

  @override
  String get custom_greeting => 'Пользовательское приветствие';

  @override
  String get interface => 'Интерфейс';

  @override
  String get gesture => 'Жесты';

  @override
  String get storage => 'Хранилище';

  @override
  String get about => 'О программе';

  @override
  String get archive_swipe => 'Архивировать (свайп вправо)';

  @override
  String get delete_swipe => 'Удалить (свайп влево)';

  @override
  String get select_student => 'Выбрать студента';

  @override
  String get built_in => 'Встроенные';

  @override
  String get add_custom_student => 'Добавить своего студента';

  @override
  String get id => 'ID';

  @override
  String get student_name => 'Имя';

  @override
  String get no_custom_students => 'Нет своих студентов';

  @override
  String get delete => 'Удалить';

  @override
  String get retry => 'Повторить';

  @override
  String get component_text => 'Текст';

  @override
  String get component_checklist => 'Список';

  @override
  String get component_drawing => 'Рисунок';

  @override
  String get component_image => 'Изображение';

  @override
  String get component_audio => 'Аудио';

  @override
  String get component_delete => 'Удалить компонент';

  @override
  String component_added(String name) {
    return 'Компонент «$name» добавлен';
  }

  @override
  String get checklist_add_item => 'Добавить пункт';

  @override
  String get clear => 'Очистить';

  @override
  String get image_url => 'Ссылка на изображение';

  @override
  String get new_group => 'Новая группа';

  @override
  String get new_chat => 'Новый диалог';

  @override
  String get group_create => 'Создать группу';

  @override
  String group_added(String name) {
    return 'Группа «$name» добавлена';
  }

  @override
  String chat_added(String name) {
    return 'Диалог «$name» добавлен';
  }

  @override
  String group_delete_confirm(String name) {
    return 'Удалить группу «$name» и все её диалоги?';
  }

  @override
  String chat_delete_confirm(String name) {
    return 'Удалить диалог с «$name»?';
  }

  @override
  String get input_name_hint => 'Введите название…';

  @override
  String get name_required => 'Название не может быть пустым';

  @override
  String get add => 'Добавить';

  @override
  String get rename => 'Переименовать';

  @override
  String get default_group => 'Группа по умолчанию';

  @override
  String get no_chats_in_group => 'Нет диалогов';

  @override
  String get no_messages => 'Нет сообщений';

  @override
  String get message_hint => 'Введите сообщение…';

  @override
  String get send => 'Отправить';

  @override
  String get tag_create => 'Создать новую метку';

  @override
  String tag_added(String name) {
    return 'Метка «$name» добавлена';
  }

  @override
  String get tag_rename => 'Переименовать метку';

  @override
  String tag_delete_confirm(String name) {
    return 'Удалить метку «$name»?';
  }

  @override
  String get storage_used => 'Занято в хранилище';

  @override
  String get cache_used => 'Занято в кэше';

  @override
  String get calculating => 'Подсчёт';

  @override
  String get refresh => 'Обновить';

  @override
  String get clear_cache_confirm => 'Очистить кэш? Заметки сохранятся.';

  @override
  String get clear_config_confirm => 'Очистить настройки? Все параметры сбросятся.';

  @override
  String get clear_success => 'Очищено';

  @override
  String get pick_from_gallery => 'Выбрать из галереи';

  @override
  String get image_pick_failed => 'Не удалось открыть галерею';

  @override
  String get edit_remark => 'Изменить примечание';

  @override
  String get remark_hint => 'Введите примечание';

  @override
  String get edit_greeting => 'Изменить приветствие';

  @override
  String get greeting_hint => 'Введите приветствие';

  @override
  String get recording => 'Запись';

  @override
  String get record_audio => 'Записать аудио';

  @override
  String get play => 'Играть';

  @override
  String get pause => 'Пауза';

  @override
  String get record_failed => 'Ошибка записи';

  @override
  String get mic_permission_denied => 'Нужно разрешение на микрофон';

  @override
  String get audio_unsupported => 'На этой платформе запись недоступна';

  @override
  String get add_image => 'Добавить изображение';

  @override
  String get take_photo => 'Сделать фото';

  @override
  String get content_hint => 'Заметка';

  @override
  String get deepseek_harness => 'DeepSeek';

  @override
  String get deepseek_enable => 'Включить ИИ';

  @override
  String get deepseek_api_key => 'API-ключ';

  @override
  String get deepseek_base_url => 'Базовый URL';

  @override
  String get deepseek_model => 'Модель';

  @override
  String get deepseek_system_prompt => 'Системная подсказка';

  @override
  String get deepseek_test_connection => 'Проверить подключение';

  @override
  String get deepseek_testing => 'Проверка';

  @override
  String get deepseek_connected => 'Подключено';

  @override
  String get deepseek_connection_failed => 'Ошибка подключения';

  @override
  String get deepseek_not_configured => 'Сначала укажите API-ключ';

  @override
  String get deepseek_saved => 'Настройки DeepSeek сохранены';

  @override
  String get ai_chat => 'DeepSeek';

  @override
  String get ai_assistant => 'DeepSeek';

  @override
  String get ai_input_hint => 'Спросите ИИ';

  @override
  String get ai_thinking => 'Думает';

  @override
  String get ai_typing => 'Печатает';

  @override
  String get ai_error => 'Ошибка ИИ';

  @override
  String get ai_insert_note => 'Вставить в заметки';

  @override
  String get ai_inserted_to_note => 'Вставлено в заметки';

  @override
  String get ai_welcome => 'Спросите что угодно. Я также могу помочь с заметками.';

  @override
  String get deepseek_disabled => 'ИИ отключён';

  @override
  String get ai_new_conversation_title => 'Новый диалог';

  @override
  String get ai_wait_reply => 'Дождитесь завершения текущего ответа';

  @override
  String get ai_conversation_created => 'Новый диалог создан';

  @override
  String get ai_mode_minimal => 'Минимальный режим';

  @override
  String get ai_mode_standard => 'Стандартный режим';

  @override
  String get ai_reasoning_low => 'Рассуждение: низкое';

  @override
  String get ai_reasoning_medium => 'Рассуждение: среднее';

  @override
  String get ai_reasoning_high => 'Рассуждение: высокое';

  @override
  String get close_image_preview => 'Закрыть просмотр изображения';

  @override
  String get close => 'Закрыть';

  @override
  String get ai_image_added => 'Изображение добавлено. DeepSeek распознает его после отправки.';

  @override
  String get stop_recording => 'Остановить запись';

  @override
  String get voice => 'Голос';

  @override
  String get ai_image_placeholder => '[Изображение]';

  @override
  String get ai_voice_placeholder => '[Голос]';

  @override
  String get ai_voice_attached => '[Пользователь прикрепил голос]';

  @override
  String get ai_new_conversation => 'Новый диалог';

  @override
  String get ai_history => 'История';

  @override
  String ai_voice_count(int count) {
    return 'Голос $count';
  }

  @override
  String get ai_recognizing_image => 'DeepSeek распознаёт изображение…';

  @override
  String get ai_empty_conversation => 'Пустой диалог';

  @override
  String get ai_delete_conversation => 'Удалить диалог';

  @override
  String get ai_search_history => 'Поиск по истории';

  @override
  String get ai_no_history => 'История диалогов пуста';

  @override
  String get ai_no_history_match => 'Нет подходящих диалогов';

  @override
  String get close_menu => 'Закрыть меню';

  @override
  String get note_blank_deleted => 'Пустая заметка удалена автоматически';

  @override
  String get note_discarded => 'Заметка отменена и удалена';

  @override
  String get select_sentence_first => 'Сначала выберите предложение';

  @override
  String get text_color => 'Цвет текста';

  @override
  String get current_sentence_only => 'Применяется только к текущему предложению';

  @override
  String get apply_label => 'Применить';

  @override
  String get choose_background => 'Выбрать фон';

  @override
  String get solid_background => 'Однотонный фон';

  @override
  String get apply_solid_color => 'Применить цвет';

  @override
  String get no_background => 'Без фона';

  @override
  String get grid_background => 'Фон-сетка';

  @override
  String get square_grid => 'Квадраты';

  @override
  String get dot_grid => 'Точки';

  @override
  String get horizontal_lines => 'Горизонтальные линии';

  @override
  String get image_background => 'Фон-изображение';

  @override
  String get change_image => 'Сменить изображение';

  @override
  String get crop_again => 'Обрезать снова';

  @override
  String get remove_image_background => 'Удалить фон-изображение';

  @override
  String get background_image_missing => 'Фоновое изображение не найдено';

  @override
  String get cannot_read_background => 'Не удалось прочитать фоновое изображение';

  @override
  String get crop_background => 'Обрезать фоновое изображение';

  @override
  String get crop_top => 'Сверху';

  @override
  String get crop_middle => 'По центру';

  @override
  String get crop_bottom => 'Снизу';

  @override
  String get zoom => 'Масштаб';

  @override
  String get crop_hint => 'Изображение автоматически заполняет заметку; обрезка меняет акцент.';

  @override
  String get use_original => 'Использовать оригинал';

  @override
  String get finish_crop => 'Завершить обрезку';

  @override
  String crop_failed(String error) {
    return 'Ошибка обрезки: $error';
  }

  @override
  String get checklist_item_hint => 'Пункт списка';

  @override
  String get insert_checklist_item => 'Вставить пункт списка';

  @override
  String get insert_divider => 'Вставить разделитель';

  @override
  String get insert_current_time => 'Вставить текущее время';

  @override
  String get body_text => 'Текст';

  @override
  String get bold => 'Жирный';

  @override
  String get italic => 'Курсив';

  @override
  String get underline => 'Подчёркивание';

  @override
  String get strikethrough => 'Зачёркнутый';

  @override
  String get align_left => 'Выровнять по левому краю';

  @override
  String get align_center => 'По центру';

  @override
  String get align_right => 'Выровнять по правому краю';

  @override
  String get select_current_sentence => 'Выделить текущее предложение';

  @override
  String word_count(int count) {
    return '$count симв.';
  }

  @override
  String get insert_content => 'Вставить содержимое';

  @override
  String get text_format => 'Форматирование текста';

  @override
  String get more => 'Ещё';

  @override
  String get select_tags => 'Выбрать метки';

  @override
  String get create_tag_first => 'Сначала создайте метку на странице меток';

  @override
  String get delete_component_confirm => 'Удалить этот компонент заметки?';

  @override
  String get no_text_content => 'Нет текста';

  @override
  String get no_checklist_items => 'Нет пунктов списка';

  @override
  String completed_count(int done, int total) {
    return 'Выполнено: $done / $total';
  }

  @override
  String get unnamed_checklist_item => 'Пункт списка без названия';

  @override
  String more_items(int count) {
    return 'Ещё элементов: $count';
  }

  @override
  String get no_drawings => 'Нет рисунков';

  @override
  String get no_images => 'Нет изображений';

  @override
  String get image_load_failed => 'Не удалось загрузить изображение';

  @override
  String get no_recording => 'Нет записи';

  @override
  String get recorded_tap_to_play => 'Записано, нажмите для воспроизведения';

  @override
  String get note_archive => 'Архив заметок';

  @override
  String get no_archived_notes => 'Нет архивных заметок';

  @override
  String get no_text_content_short => 'Нет текста';

  @override
  String get restore => 'Восстановить';

  @override
  String get momotalk_archive => 'Архив MomoTalk';

  @override
  String get no_archived_chats => 'Нет архивных диалогов';

  @override
  String get exit_unsaved_title => 'Несохранённые изменения';

  @override
  String get exit_unsaved_message => 'Обнаружены несохранённые изменения. Сохранить перед выходом?';

  @override
  String get discard => 'Отменить';

  @override
  String get right_swipe_action => 'Действие свайпа вправо';

  @override
  String get left_swipe_action => 'Действие свайпа влево';

  @override
  String get gesture_pin => 'Закрепить';

  @override
  String get gesture_archive => 'В архив';

  @override
  String get gesture_mark => 'Отметить';

  @override
  String image_send_failed(String error) {
    return 'Не удалось отправить изображение: $error';
  }

  @override
  String get gallery_load_failed => 'Не удалось загрузить галерею портретов';

  @override
  String get gallery_not_found => 'Не найдены варианты портрета для этого студента';

  @override
  String get portrait_variants => 'Варианты портрета';

  @override
  String get screenshot_failed => 'Не удалось сделать снимок экрана';

  @override
  String get message_reorder => 'Изменить порядок';

  @override
  String get message_edit => 'Изменить';

  @override
  String get message_transform => 'Преобразовать';

  @override
  String get transform_developing => 'Функция преобразования скоро появится';

  @override
  String get edit_message => 'Изменить сообщение';

  @override
  String get enter_new_message => 'Введите новое сообщение';

  @override
  String get not_enough_messages => 'Недостаточно сообщений для изменения порядка';

  @override
  String get drag_to_reorder => 'Перетащите сообщения для изменения порядка';

  @override
  String get switch_student => 'Сменить студента';

  @override
  String get emoji => 'Эмодзи';

  @override
  String get image => 'Изображение';

  @override
  String get student => 'Студент';

  @override
  String get send_as_student => 'Отправить как студент';

  @override
  String get send_as_teacher => 'Отправить как учитель';

  @override
  String get screenshot => 'Снимок экрана';

  @override
  String get current_identity_student => 'Отправка от имени студента';

  @override
  String get current_identity_teacher => 'Отправка от имени преподавателя';

  @override
  String get gallery => 'Галерея';

  @override
  String get stroke_width => 'Толщина линии';

  @override
  String get undo => 'Отменить';

  @override
  String get redo => 'Повторить';

  @override
  String get drawing_eraser => 'Ластик';

  @override
  String get drawing_highlighter => 'Маркер';

  @override
  String get drawing_pencil => 'Карандаш';

  @override
  String get drawing_marker => 'Фломастер';

  @override
  String get version => 'Версия';

  @override
  String get developer => 'Разработчик';

  @override
  String get open_source_license => 'Лицензия открытого кода';

  @override
  String get clear_drawing_confirm => 'Очистить рисунок?';

  @override
  String get custom_color => 'Свой цвет';

  @override
  String get search_students => 'Поиск студентов';

  @override
  String get no_student_matches => 'Нет подходящих студентов';

  @override
  String get ai_image_model_warning => 'Эта модель может не поддерживать изображения. Для распознавания выберите модель со зрением.';

  @override
  String get select_all_document => 'Выделить весь текст';

  @override
  String get copy_all_text => 'Копировать весь текст';

  @override
  String get all_text_copied => 'Весь текст скопирован';

  @override
  String get move_canvas => 'Перемещение холста';

  @override
  String get center_canvas => 'Центрировать холст';

  @override
  String get zoom_in => 'Увеличить';

  @override
  String get zoom_out => 'Уменьшить';

  @override
  String get canvas_background => 'Фон холста';

  @override
  String get canvas_style_grid => 'Сетка';

  @override
  String get canvas_style_dots => 'Точки';

  @override
  String get canvas_style_none => 'Без фона';

  @override
  String ai_conversation_save_failed(String error) {
    return 'Не удалось сохранить беседу: $error';
  }

  @override
  String get save_failed_retrying => 'Не удалось сохранить. Изменения сохранены и будут повторены.';

  @override
  String get recovery_draft_found => 'Найден несохранённый черновик';

  @override
  String get recovery_draft_message => 'Есть черновик восстановления из прошлого сеанса. Восстановить?';

  @override
  String get open_menu => 'Открыть меню';

  @override
  String get theme_system => 'Системная';

  @override
  String get theme_light => 'Светлая';

  @override
  String get theme_dark => 'Тёмная';

  @override
  String get search_notes => 'Поиск заметок';

  @override
  String get search_notes_hint => 'Поиск по заголовкам, содержимому и тегам';

  @override
  String get search_empty_title => 'Введите запрос для поиска';

  @override
  String get search_empty_message => 'Поиск по заголовкам, тексту, пунктам списка и тегам.';

  @override
  String get search_no_results_title => 'Совпадений не найдено';

  @override
  String get search_no_results_message => 'Попробуйте более короткий запрос или снимите фильтр по тегу.';

  @override
  String get search_clear => 'Очистить поиск';

  @override
  String get untitled => 'Без названия';

  @override
  String search_results_count(int count) {
    return 'Результатов: $count';
  }

  @override
  String get copy_reply => 'Копировать ответ';

  @override
  String get regenerate_reply => 'Сгенерировать заново';

  @override
  String get reply_copied => 'Ответ скопирован';

  @override
  String get copy_reply_failed => 'Не удалось скопировать ответ';

  @override
  String get export_markdown => 'Копировать заметки как Markdown';

  @override
  String get export_markdown_subtitle => 'Копировать все активные заметки в буфер обмена';

  @override
  String get export_backup => 'Сохранить резервную копию JSON';

  @override
  String get export_backup_subtitle => 'Сохранить заметки, теги, чаты и диалоги ИИ';

  @override
  String get export_markdown_done => 'Заметки скопированы в буфер обмена';

  @override
  String export_backup_saved(String path) {
    return 'Резервная копия сохранена в $path';
  }

  @override
  String export_failed(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get add_text_component => 'Добавить текстовый компонент';

  @override
  String get message_actions => 'Действия с сообщением';

  @override
  String get copy => 'Копировать';

  @override
  String get select_text => 'Выделить текст';

  @override
  String get delete_message_confirm => 'Удалить это сообщение?';

  @override
  String get delete_message_body => 'Это сообщение будет удалено из диалога.';

  @override
  String get regenerate_confirm => 'Сгенерировать этот ответ заново?';

  @override
  String get remove_following_messages => 'Сообщения после этого ответа будут удалены, так как контекст изменится.';

  @override
  String get edit_message_hint => 'Редактировать текст сообщения';

  @override
  String get about_tagline => 'Тихое место для заметок, идей и разговоров.';
}
