// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get note => 'ノート';

  @override
  String get label => 'ラベル';

  @override
  String get motalk => 'MomoTalk';

  @override
  String get settings => '設定';

  @override
  String get general => '一般';

  @override
  String get language => '言語';

  @override
  String get dark_theme => 'ダークテーマ';

  @override
  String get the_quick_brown_fox_jumps_over_the_lazy_dog => '素早い茶色のキツネが怠け者の犬を飛び越える';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get title => 'タイトル';

  @override
  String get quit => '保存して終了しますか？';

  @override
  String get size => '拡大縮小';

  @override
  String get normal => 'デフォルト';

  @override
  String get theme => 'テーマ';

  @override
  String get color_scheme => '配色';

  @override
  String get default_color_scheme => 'デフォルト配色';

  @override
  String get optimize_storage => 'ストレージを最適化';

  @override
  String get optimize_storage_subtitle => '未使用のメディアを削除し、ローカルデータベースを圧縮します';

  @override
  String get optimize_storage_confirm => '参照されていないメディア、古いエクスポート、データベースを整理しますか？ノートは保持されます。';

  @override
  String optimize_storage_done(String size) {
    return '$size を解放しました';
  }

  @override
  String get message_student => '学生';

  @override
  String get message_teacher => '先生';

  @override
  String get message => 'メッセージ';

  @override
  String get custom => 'カスタム';

  @override
  String get character => '学生';

  @override
  String get clear_failed => 'クリア失敗!';

  @override
  String get clear_config => '設定をクリア';

  @override
  String get clear_cache => 'キャッシュをクリア';

  @override
  String get auto_save => '自動保存';

  @override
  String get dialog => 'ダイアログ';

  @override
  String get font => 'フォント';

  @override
  String get radius => '半径';

  @override
  String get settings_saved => '設定を保存しました!';

  @override
  String get apply => '変更を適用';

  @override
  String get restore_defaults => 'デフォルトに戻す';

  @override
  String get restore_confirm => 'すべての設定をデフォルトに戻しますか？';

  @override
  String get defaults_restored => 'デフォルトに戻しました';

  @override
  String get show_student_surname => '生徒の姓を表示';

  @override
  String get reverse_name => '姓名を逆にする';

  @override
  String get student_name_language => '生徒名の言語';

  @override
  String get language_chinese => '中国語';

  @override
  String get language_japanese => '日本語';

  @override
  String get language_english => '英語';

  @override
  String get language_korean => '韓国語';

  @override
  String get language_spanish => 'スペイン語';

  @override
  String get language_russian => 'ロシア語';

  @override
  String get remark => '備考';

  @override
  String get teacher_avatar => '先生のアイコン';

  @override
  String get custom_student => 'カスタム生徒';

  @override
  String get custom_greeting => 'カスタム挨拶';

  @override
  String get interface => 'インターフェース';

  @override
  String get gesture => 'ジェスチャー';

  @override
  String get storage => 'ストレージ';

  @override
  String get about => 'このアプリについて';

  @override
  String get archive_swipe => 'アーカイブ（右スワイプ）';

  @override
  String get delete_swipe => '削除（左スワイプ）';

  @override
  String get select_student => '生徒を選択';

  @override
  String get built_in => '内蔵';

  @override
  String get add_custom_student => 'カスタム生徒を追加';

  @override
  String get id => 'ID';

  @override
  String get student_name => '名前';

  @override
  String get no_custom_students => 'カスタム生徒はありません';

  @override
  String get delete => '削除';

  @override
  String get retry => '再試行';

  @override
  String get component_text => 'テキスト';

  @override
  String get component_checklist => 'チェックリスト';

  @override
  String get component_drawing => 'お絵かき';

  @override
  String get component_image => '画像';

  @override
  String get component_audio => '音声';

  @override
  String get component_delete => 'コンポーネントを削除';

  @override
  String component_added(String name) {
    return '$nameコンポーネントを追加しました';
  }

  @override
  String get checklist_add_item => '項目を追加';

  @override
  String get clear => 'クリア';

  @override
  String get image_url => '画像URL';

  @override
  String get new_group => '新しいグループ';

  @override
  String get new_chat => '新しい会話';

  @override
  String get group_create => 'グループを作成';

  @override
  String group_added(String name) {
    return 'グループ「$name」を追加しました';
  }

  @override
  String chat_added(String name) {
    return '会話「$name」を追加しました';
  }

  @override
  String group_delete_confirm(String name) {
    return 'グループ「$name」とすべての会話を削除しますか？';
  }

  @override
  String chat_delete_confirm(String name) {
    return '「$name」との会話を削除しますか？';
  }

  @override
  String get input_name_hint => '名前を入力…';

  @override
  String get name_required => '名前を入力してください';

  @override
  String get add => '追加';

  @override
  String get rename => '名前を変更';

  @override
  String get default_group => 'デフォルトグループ';

  @override
  String get no_chats_in_group => '会話がありません';

  @override
  String get no_messages => 'メッセージがありません';

  @override
  String get message_hint => 'メッセージを入力…';

  @override
  String get send => '送信';

  @override
  String get tag_create => '新しいラベルを作成';

  @override
  String tag_added(String name) {
    return 'ラベル「$name」を追加しました';
  }

  @override
  String get tag_rename => 'ラベルの名前を変更';

  @override
  String tag_delete_confirm(String name) {
    return 'ラベル「$name」を削除しますか？';
  }

  @override
  String get storage_used => 'ストレージ使用量';

  @override
  String get cache_used => 'キャッシュ使用量';

  @override
  String get calculating => '計算中';

  @override
  String get refresh => '更新';

  @override
  String get clear_cache_confirm => 'キャッシュをクリアしますか？ノートは削除されません。';

  @override
  String get clear_config_confirm => '設定をクリアしますか？すべての設定が初期化されます。';

  @override
  String get clear_success => 'クリアしました';

  @override
  String get pick_from_gallery => 'ギャラリーから選択';

  @override
  String get image_pick_failed => 'ギャラリーを開けませんでした';

  @override
  String get edit_remark => '備考を編集';

  @override
  String get remark_hint => '備考を入力';

  @override
  String get edit_greeting => '挨拶を編集';

  @override
  String get greeting_hint => '挨拶を入力';

  @override
  String get recording => '録音中';

  @override
  String get record_audio => '音声を録音';

  @override
  String get play => '再生';

  @override
  String get pause => '一時停止';

  @override
  String get record_failed => '録音に失敗しました';

  @override
  String get mic_permission_denied => 'マイクの権限が必要です';

  @override
  String get audio_unsupported => 'このプラットフォームは録音に対応していません';

  @override
  String get add_image => '画像を追加';

  @override
  String get take_photo => '写真を撮る';

  @override
  String get content_hint => 'メモ';

  @override
  String get deepseek_harness => 'DeepSeek';

  @override
  String get deepseek_enable => 'AI を有効にする';

  @override
  String get deepseek_api_key => 'API キー';

  @override
  String get deepseek_base_url => 'ベース URL';

  @override
  String get deepseek_model => 'モデル';

  @override
  String get deepseek_system_prompt => 'システムプロンプト';

  @override
  String get deepseek_test_connection => '接続をテスト';

  @override
  String get deepseek_testing => 'テスト中';

  @override
  String get deepseek_connected => '接続しました';

  @override
  String get deepseek_connection_failed => '接続に失敗しました';

  @override
  String get deepseek_not_configured => '先に API キーを設定してください';

  @override
  String get deepseek_saved => 'DeepSeek 設定を保存しました';

  @override
  String get ai_chat => 'DeepSeek';

  @override
  String get ai_assistant => 'DeepSeek';

  @override
  String get ai_input_hint => 'AI に質問';

  @override
  String get ai_thinking => '考え中';

  @override
  String get ai_typing => '入力中';

  @override
  String get ai_error => 'AI エラー';

  @override
  String get ai_insert_note => 'ノートに挿入';

  @override
  String get ai_inserted_to_note => 'ノートに挿入しました';

  @override
  String get ai_welcome => '何でも聞いてください。ノート作成のお手伝いもできます。';

  @override
  String get deepseek_disabled => 'AI は無効です';

  @override
  String get ai_new_conversation_title => '新しい会話';

  @override
  String get ai_wait_reply => '現在の応答が完了するまでお待ちください';

  @override
  String get ai_conversation_created => '新しい会話を作成しました';

  @override
  String get ai_mode_minimal => 'ミニマルモード';

  @override
  String get ai_mode_standard => '標準モード';

  @override
  String get ai_reasoning_low => '推論：低';

  @override
  String get ai_reasoning_medium => '推論：中';

  @override
  String get ai_reasoning_high => '推論：高';

  @override
  String get close_image_preview => '画像プレビューを閉じる';

  @override
  String get close => '閉じる';

  @override
  String get ai_image_added => '画像を追加しました。送信後に DeepSeek が認識します。';

  @override
  String get stop_recording => '録音を停止';

  @override
  String get voice => '音声';

  @override
  String get ai_image_placeholder => '[画像]';

  @override
  String get ai_voice_placeholder => '[音声]';

  @override
  String get ai_voice_attached => '[ユーザーが音声を添付]';

  @override
  String get ai_new_conversation => '新しい会話';

  @override
  String get ai_history => '履歴';

  @override
  String ai_voice_count(int count) {
    return '音声 $count';
  }

  @override
  String get ai_recognizing_image => 'DeepSeek が画像を認識しています…';

  @override
  String get ai_empty_conversation => '空の会話';

  @override
  String get ai_delete_conversation => '会話を削除';

  @override
  String get ai_search_history => '会話履歴を検索';

  @override
  String get ai_no_history => '会話履歴はありません';

  @override
  String get ai_no_history_match => '一致する会話はありません';

  @override
  String get close_menu => 'メニューを閉じる';

  @override
  String get note_blank_deleted => '空白のメモを自動削除しました';

  @override
  String get note_discarded => 'メモを破棄して削除しました';

  @override
  String get select_sentence_first => '先に文を選択してください';

  @override
  String get text_color => '文字色';

  @override
  String get current_sentence_only => '現在の文にのみ適用されます';

  @override
  String get apply_label => '適用';

  @override
  String get choose_background => '背景を選択';

  @override
  String get solid_background => '単色背景';

  @override
  String get apply_solid_color => '単色を適用';

  @override
  String get no_background => '背景なし';

  @override
  String get grid_background => 'グリッド背景';

  @override
  String get square_grid => '正方形';

  @override
  String get dot_grid => 'ドット';

  @override
  String get horizontal_lines => '横線';

  @override
  String get image_background => '画像背景';

  @override
  String get change_image => '画像を変更';

  @override
  String get crop_again => '再トリミング';

  @override
  String get remove_image_background => '画像背景を削除';

  @override
  String get background_image_missing => '背景画像が見つかりません';

  @override
  String get cannot_read_background => '背景画像を読み込めません';

  @override
  String get crop_background => '背景画像をトリミング';

  @override
  String get crop_top => '上';

  @override
  String get crop_middle => '中央';

  @override
  String get crop_bottom => '下';

  @override
  String get zoom => 'ズーム';

  @override
  String get crop_hint => '画像はメモ全体に自動で表示されます。トリミングで重点領域を調整できます。';

  @override
  String get use_original => '元画像を使用';

  @override
  String get finish_crop => 'トリミング完了';

  @override
  String crop_failed(String error) {
    return 'トリミングに失敗しました: $error';
  }

  @override
  String get checklist_item_hint => 'チェック項目';

  @override
  String get insert_checklist_item => 'チェック項目を挿入';

  @override
  String get insert_divider => '区切り線を挿入';

  @override
  String get insert_current_time => '現在時刻を挿入';

  @override
  String get body_text => '本文';

  @override
  String get bold => '太字';

  @override
  String get italic => '斜体';

  @override
  String get underline => '下線';

  @override
  String get strikethrough => '取り消し線';

  @override
  String get align_left => '左揃え';

  @override
  String get align_center => '中央揃え';

  @override
  String get align_right => '右揃え';

  @override
  String get select_current_sentence => '現在の文をすべて選択';

  @override
  String word_count(int count) {
    return '$count 文字';
  }

  @override
  String get insert_content => 'コンテンツを挿入';

  @override
  String get text_format => '文字書式';

  @override
  String get more => 'その他';

  @override
  String get select_tags => 'ラベルを選択';

  @override
  String get create_tag_first => '先にラベルページでラベルを作成してください';

  @override
  String get delete_component_confirm => 'このメモコンポーネントを削除しますか？';

  @override
  String get no_text_content => 'テキストはありません';

  @override
  String get no_checklist_items => 'チェック項目はありません';

  @override
  String completed_count(int done, int total) {
    return '$done / $total 完了';
  }

  @override
  String get unnamed_checklist_item => '無題のチェック項目';

  @override
  String more_items(int count) {
    return '他 $count 件';
  }

  @override
  String get no_drawings => '描画はありません';

  @override
  String get no_images => '画像はありません';

  @override
  String get image_load_failed => '画像を読み込めません';

  @override
  String get no_recording => '録音はありません';

  @override
  String get recorded_tap_to_play => '録音済み。タップして再生';

  @override
  String get note_archive => 'メモアーカイブ';

  @override
  String get no_archived_notes => 'アーカイブされたメモはありません';

  @override
  String get no_text_content_short => 'テキストなし';

  @override
  String get restore => '復元';

  @override
  String get momotalk_archive => 'MomoTalk アーカイブ';

  @override
  String get no_archived_chats => 'アーカイブされた会話はありません';

  @override
  String get exit_unsaved_title => '未保存の変更があります';

  @override
  String get exit_unsaved_message => '未保存の変更があります。保存して終了しますか？';

  @override
  String get discard => '破棄';

  @override
  String get right_swipe_action => '右スワイプの動作';

  @override
  String get left_swipe_action => '左スワイプの動作';

  @override
  String get gesture_pin => '固定';

  @override
  String get gesture_archive => 'アーカイブ';

  @override
  String get gesture_mark => 'マーク';

  @override
  String image_send_failed(String error) {
    return '画像の送信に失敗しました: $error';
  }

  @override
  String get gallery_load_failed => '立ち絵差分の読み込みに失敗しました';

  @override
  String get gallery_not_found => 'この生徒の立ち絵差分が見つかりません';

  @override
  String get portrait_variants => '立ち絵差分';

  @override
  String get screenshot_failed => 'スクリーンショットに失敗しました';

  @override
  String get message_reorder => '並べ替え';

  @override
  String get message_edit => '編集';

  @override
  String get message_transform => '変換';

  @override
  String get transform_developing => '変換機能は開発中です';

  @override
  String get edit_message => 'メッセージを編集';

  @override
  String get enter_new_message => '新しいメッセージを入力';

  @override
  String get not_enough_messages => '並べ替えるメッセージが足りません';

  @override
  String get drag_to_reorder => 'ドラッグしてメッセージを並べ替え';

  @override
  String get switch_student => '生徒を切り替え';

  @override
  String get emoji => '絵文字';

  @override
  String get image => '画像';

  @override
  String get student => '生徒';

  @override
  String get send_as_student => '生徒として送信';

  @override
  String get send_as_teacher => '先生として送信';

  @override
  String get screenshot => 'スクリーンショット';

  @override
  String get current_identity_student => '現在は生徒として送信中';

  @override
  String get current_identity_teacher => '現在は先生として送信中';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get stroke_width => '線の太さ';

  @override
  String get undo => '元に戻す';

  @override
  String get redo => 'やり直す';

  @override
  String get drawing_eraser => '消しゴム';

  @override
  String get drawing_highlighter => 'ハイライター';

  @override
  String get drawing_pencil => '鉛筆';

  @override
  String get drawing_marker => 'マーカー';

  @override
  String get version => 'バージョン';

  @override
  String get developer => '開発者';

  @override
  String get open_source_license => 'オープンソースライセンス';

  @override
  String get clear_drawing_confirm => '描画を消去しますか？';

  @override
  String get custom_color => 'カスタムカラー';

  @override
  String get search_students => '生徒を検索';

  @override
  String get no_student_matches => '一致する生徒はいません';

  @override
  String get ai_image_model_warning => 'このモデルは画像入力に対応していない可能性があります。画像認識には視覚対応モデルに切り替えてください。';

  @override
  String get select_all_document => '全文を選択';

  @override
  String get copy_all_text => '全文をコピー';

  @override
  String get all_text_copied => '全文をコピーしました';

  @override
  String get move_canvas => 'キャンバスを移動';

  @override
  String get center_canvas => 'キャンバスを中央に';

  @override
  String get zoom_in => '拡大';

  @override
  String get zoom_out => '縮小';

  @override
  String get canvas_background => 'キャンバス背景';

  @override
  String get canvas_style_grid => 'グリッド';

  @override
  String get canvas_style_dots => 'ドット';

  @override
  String get canvas_style_none => '背景なし';

  @override
  String ai_conversation_save_failed(String error) {
    return '会話を保存できませんでした：$error';
  }

  @override
  String get save_failed_retrying => '保存に失敗しました。変更は保持され、再試行します。';

  @override
  String get recovery_draft_found => '未保存の下書きがあります';

  @override
  String get recovery_draft_message => '前回の編集で作成された復元用下書きがあります。復元しますか？';

  @override
  String get open_menu => 'メニューを開く';

  @override
  String get theme_system => 'システム';

  @override
  String get theme_light => 'ライト';

  @override
  String get theme_dark => 'ダーク';

  @override
  String get search_notes => 'ノートを検索';

  @override
  String get search_notes_hint => 'タイトル、内容、タグを検索';

  @override
  String get search_empty_title => 'キーワードを入力して検索';

  @override
  String get search_empty_message => 'タイトル、本文、チェックリスト、タグを検索できます。';

  @override
  String get search_no_results_title => '一致するノートがありません';

  @override
  String get search_no_results_message => '短いキーワードにするか、タグフィルターを解除してください。';

  @override
  String get search_clear => '検索をクリア';

  @override
  String get untitled => '無題';

  @override
  String search_results_count(int count) {
    return '$count 件';
  }

  @override
  String get copy_reply => '返信をコピー';

  @override
  String get regenerate_reply => '再生成';

  @override
  String get reply_copied => '返信をコピーしました';

  @override
  String get copy_reply_failed => '返信をコピーできませんでした';

  @override
  String get export_markdown => 'ノートを Markdown でコピー';

  @override
  String get export_markdown_subtitle => 'すべてのアクティブなノートをクリップボードにコピー';

  @override
  String get export_backup => 'JSON バックアップを保存';

  @override
  String get export_backup_subtitle => 'ノート、タグ、チャット、AI 会話を保存';

  @override
  String get export_markdown_done => 'ノートをクリップボードにコピーしました';

  @override
  String export_backup_saved(String path) {
    return 'バックアップを $path に保存しました';
  }

  @override
  String export_failed(String error) {
    return 'エクスポートに失敗しました：$error';
  }

  @override
  String get add_text_component => 'テキストを追加';

  @override
  String get message_actions => 'メッセージ操作';

  @override
  String get copy => 'コピー';

  @override
  String get select_text => 'テキストを選択';

  @override
  String get delete_message_confirm => 'このメッセージを削除しますか？';

  @override
  String get delete_message_body => 'このメッセージは会話から削除されます。';

  @override
  String get regenerate_confirm => 'この返信を再生成しますか？';

  @override
  String get remove_following_messages => 'コンテキストが変わるため、この返信より後のメッセージは削除されます。';

  @override
  String get edit_message_hint => 'メッセージを編集';

  @override
  String get about_tagline => 'メモやアイデア、会話を静かに残す場所。';
}
