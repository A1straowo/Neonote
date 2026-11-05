// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get note => '메모';

  @override
  String get label => '태그';

  @override
  String get motalk => 'MomoTalk';

  @override
  String get settings => '설정';

  @override
  String get general => '일반';

  @override
  String get language => '언어';

  @override
  String get dark_theme => '다크 테마';

  @override
  String get the_quick_brown_fox_jumps_over_the_lazy_dog => '빠른 갈색 여우가 게으른 개를 뛰어넘는다';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get title => '제목';

  @override
  String get quit => '저장하고 나가시겠습니까?';

  @override
  String get size => '크기 조정';

  @override
  String get normal => '기본';

  @override
  String get theme => '테마';

  @override
  String get color_scheme => '색상 구성';

  @override
  String get default_color_scheme => '기본 색상';

  @override
  String get optimize_storage => '저장공간 최적화';

  @override
  String get optimize_storage_subtitle => '사용하지 않는 미디어를 정리하고 로컬 데이터베이스를 압축합니다';

  @override
  String get optimize_storage_confirm => '참조되지 않는 미디어, 이전 내보내기 사본을 삭제하고 데이터베이스를 압축할까요? 노트는 유지됩니다.';

  @override
  String optimize_storage_done(String size) {
    return '$size 확보됨';
  }

  @override
  String get message_student => '학생';

  @override
  String get message_teacher => '선생님';

  @override
  String get message => '메시지';

  @override
  String get custom => '사용자 정의';

  @override
  String get character => '학생';

  @override
  String get clear_failed => '삭제 실패';

  @override
  String get clear_config => '설정 초기화';

  @override
  String get clear_cache => '캐시 삭제';

  @override
  String get auto_save => '자동 저장';

  @override
  String get dialog => '대화 상자';

  @override
  String get font => '글꼴';

  @override
  String get radius => '모서리 둥글기';

  @override
  String get settings_saved => '현재 설정이 저장되었습니다';

  @override
  String get apply => '변경 사항 적용';

  @override
  String get restore_defaults => '기본값으로 복원';

  @override
  String get restore_confirm => '모든 설정을 기본값으로 복원하시겠습니까?';

  @override
  String get defaults_restored => '기본값이 복원되었습니다';

  @override
  String get show_student_surname => '학생 성 표시';

  @override
  String get reverse_name => '이름 순서 반전';

  @override
  String get student_name_language => '학생 이름 언어';

  @override
  String get language_chinese => '중국어';

  @override
  String get language_japanese => '일본어';

  @override
  String get language_english => '영어';

  @override
  String get language_korean => '한국어';

  @override
  String get language_spanish => '스페인어';

  @override
  String get language_russian => '러시아어';

  @override
  String get remark => '비고';

  @override
  String get teacher_avatar => '선생님 프로필 사진';

  @override
  String get custom_student => '사용자 지정 학생';

  @override
  String get custom_greeting => '사용자 지정 인사말';

  @override
  String get interface => '인터페이스';

  @override
  String get gesture => '제스처';

  @override
  String get storage => '저장 공간';

  @override
  String get about => '정보';

  @override
  String get archive_swipe => '보관(오른쪽 스와이프)';

  @override
  String get delete_swipe => '삭제(왼쪽 스와이프)';

  @override
  String get select_student => '학생 선택';

  @override
  String get built_in => '내장';

  @override
  String get add_custom_student => '사용자 정의 학생 추가';

  @override
  String get id => 'ID';

  @override
  String get student_name => '이름';

  @override
  String get no_custom_students => '사용자 정의 학생 없음';

  @override
  String get delete => '삭제';

  @override
  String get retry => '다시 시도';

  @override
  String get component_text => '텍스트';

  @override
  String get component_checklist => '체크리스트';

  @override
  String get component_drawing => '그리기';

  @override
  String get component_image => '이미지';

  @override
  String get component_audio => '오디오';

  @override
  String get component_delete => '컴포넌트 삭제';

  @override
  String component_added(String name) {
    return '$name 컴포넌트를 추가했습니다';
  }

  @override
  String get checklist_add_item => '항목 추가';

  @override
  String get clear => '지우기';

  @override
  String get image_url => '이미지 URL';

  @override
  String get new_group => '새 그룹';

  @override
  String get new_chat => '새 대화';

  @override
  String get group_create => '그룹 만들기';

  @override
  String group_added(String name) {
    return '그룹 “$name”을(를) 추가했습니다';
  }

  @override
  String chat_added(String name) {
    return '대화 “$name”을(를) 추가했습니다';
  }

  @override
  String group_delete_confirm(String name) {
    return '그룹 “$name”과(와) 모든 대화를 삭제할까요?';
  }

  @override
  String chat_delete_confirm(String name) {
    return '“$name”과(와)의 대화를 삭제할까요?';
  }

  @override
  String get input_name_hint => '이름 입력…';

  @override
  String get name_required => '이름을 입력하세요';

  @override
  String get add => '추가';

  @override
  String get rename => '이름 바꾸기';

  @override
  String get default_group => '기본 그룹';

  @override
  String get no_chats_in_group => '대화가 없습니다';

  @override
  String get no_messages => '메시지가 없습니다';

  @override
  String get message_hint => '메시지 입력…';

  @override
  String get send => '전송';

  @override
  String get tag_create => '새 라벨 만들기';

  @override
  String tag_added(String name) {
    return '라벨 “$name”을(를) 추가했습니다';
  }

  @override
  String get tag_rename => '라벨 이름 바꾸기';

  @override
  String tag_delete_confirm(String name) {
    return '라벨 “$name”을(를) 삭제할까요?';
  }

  @override
  String get storage_used => '저장 공간 사용량';

  @override
  String get cache_used => '캐시 사용량';

  @override
  String get calculating => '계산 중';

  @override
  String get refresh => '새로 고침';

  @override
  String get clear_cache_confirm => '캐시를 삭제할까요? 노트는 삭제되지 않습니다.';

  @override
  String get clear_config_confirm => '설정을 초기화할까요? 모든 개인 설정이 기본값으로 돌아갑니다.';

  @override
  String get clear_success => '삭제되었습니다';

  @override
  String get pick_from_gallery => '갤러리에서 선택';

  @override
  String get image_pick_failed => '갤러리를 열 수 없습니다';

  @override
  String get edit_remark => '비고 편집';

  @override
  String get remark_hint => '비고 입력';

  @override
  String get edit_greeting => '인사말 편집';

  @override
  String get greeting_hint => '인사말 입력';

  @override
  String get recording => '녹음 중';

  @override
  String get record_audio => '오디오 녹음';

  @override
  String get play => '재생';

  @override
  String get pause => '일시정지';

  @override
  String get record_failed => '녹음 실패';

  @override
  String get mic_permission_denied => '마이크 권한이 필요합니다';

  @override
  String get audio_unsupported => '이 플랫폼은 녹음을 지원하지 않습니다';

  @override
  String get add_image => '이미지 추가';

  @override
  String get take_photo => '사진 찍기';

  @override
  String get content_hint => '메모';

  @override
  String get deepseek_harness => 'DeepSeek';

  @override
  String get deepseek_enable => 'AI 사용';

  @override
  String get deepseek_api_key => 'API 키';

  @override
  String get deepseek_base_url => '기본 URL';

  @override
  String get deepseek_model => '모델';

  @override
  String get deepseek_system_prompt => '시스템 프롬프트';

  @override
  String get deepseek_test_connection => '연결 테스트';

  @override
  String get deepseek_testing => '테스트 중';

  @override
  String get deepseek_connected => '연결되었습니다';

  @override
  String get deepseek_connection_failed => '연결 실패';

  @override
  String get deepseek_not_configured => '먼저 API 키를 설정하세요';

  @override
  String get deepseek_saved => 'DeepSeek 설정이 저장되었습니다';

  @override
  String get ai_chat => 'DeepSeek';

  @override
  String get ai_assistant => 'DeepSeek';

  @override
  String get ai_input_hint => 'AI에게 질문';

  @override
  String get ai_thinking => '생각 중';

  @override
  String get ai_typing => '입력 중';

  @override
  String get ai_error => 'AI 오류';

  @override
  String get ai_insert_note => '노트에 삽입';

  @override
  String get ai_inserted_to_note => '노트에 삽입했습니다';

  @override
  String get ai_welcome => '무엇이든 물어보세요. 노트 작성을 도와드릴 수도 있습니다.';

  @override
  String get deepseek_disabled => 'AI가 비활성화되었습니다';

  @override
  String get ai_new_conversation_title => '새 대화';

  @override
  String get ai_wait_reply => '현재 응답이 완료될 때까지 기다려 주세요';

  @override
  String get ai_conversation_created => '새 대화가 생성되었습니다';

  @override
  String get ai_mode_minimal => '간단 모드';

  @override
  String get ai_mode_standard => '표준 모드';

  @override
  String get ai_reasoning_low => '추론: 낮음';

  @override
  String get ai_reasoning_medium => '추론: 보통';

  @override
  String get ai_reasoning_high => '추론: 높음';

  @override
  String get close_image_preview => '이미지 미리보기 닫기';

  @override
  String get close => '닫기';

  @override
  String get ai_image_added => '이미지가 추가되었습니다. 전송 후 DeepSeek가 인식합니다.';

  @override
  String get stop_recording => '녹음 중지';

  @override
  String get voice => '음성';

  @override
  String get ai_image_placeholder => '[이미지]';

  @override
  String get ai_voice_placeholder => '[음성]';

  @override
  String get ai_voice_attached => '[사용자가 음성을 첨부함]';

  @override
  String get ai_new_conversation => '새 대화';

  @override
  String get ai_history => '기록';

  @override
  String ai_voice_count(int count) {
    return '음성 $count';
  }

  @override
  String get ai_recognizing_image => 'DeepSeek가 이미지를 인식하는 중…';

  @override
  String get ai_empty_conversation => '빈 대화';

  @override
  String get ai_delete_conversation => '대화 삭제';

  @override
  String get ai_search_history => '대화 기록 검색';

  @override
  String get ai_no_history => '대화 기록이 없습니다';

  @override
  String get ai_no_history_match => '일치하는 대화가 없습니다';

  @override
  String get close_menu => '메뉴 닫기';

  @override
  String get note_blank_deleted => '빈 메모가 자동 삭제되었습니다';

  @override
  String get note_discarded => '메모를 버리고 삭제했습니다';

  @override
  String get select_sentence_first => '먼저 문장을 선택하세요';

  @override
  String get text_color => '글자 색상';

  @override
  String get current_sentence_only => '현재 문장에만 적용됩니다';

  @override
  String get apply_label => '적용';

  @override
  String get choose_background => '배경 선택';

  @override
  String get solid_background => '단색 배경';

  @override
  String get apply_solid_color => '색상 적용';

  @override
  String get no_background => '배경 없음';

  @override
  String get grid_background => '격자 배경';

  @override
  String get square_grid => '정사각형';

  @override
  String get dot_grid => '점';

  @override
  String get horizontal_lines => '가로선';

  @override
  String get image_background => '이미지 배경';

  @override
  String get change_image => '이미지 변경';

  @override
  String get crop_again => '다시 자르기';

  @override
  String get remove_image_background => '이미지 배경 제거';

  @override
  String get background_image_missing => '배경 이미지를 찾을 수 없습니다';

  @override
  String get cannot_read_background => '배경 이미지를 읽을 수 없습니다';

  @override
  String get crop_background => '배경 이미지 자르기';

  @override
  String get crop_top => '위';

  @override
  String get crop_middle => '가운데';

  @override
  String get crop_bottom => '아래';

  @override
  String get zoom => '확대/축소';

  @override
  String get crop_hint => '이미지는 메모를 자동으로 채웁니다. 자르기로 중점 영역을 조정하세요.';

  @override
  String get use_original => '원본 사용';

  @override
  String get finish_crop => '자르기 완료';

  @override
  String crop_failed(String error) {
    return '자르기 실패: $error';
  }

  @override
  String get checklist_item_hint => '체크리스트 항목';

  @override
  String get insert_checklist_item => '체크리스트 항목 삽입';

  @override
  String get insert_divider => '구분선 삽입';

  @override
  String get insert_current_time => '현재 시간 삽입';

  @override
  String get body_text => '본문';

  @override
  String get bold => '굵게';

  @override
  String get italic => '기울임';

  @override
  String get underline => '밑줄';

  @override
  String get strikethrough => '취소선';

  @override
  String get align_left => '왼쪽 정렬';

  @override
  String get align_center => '가운데 정렬';

  @override
  String get align_right => '오른쪽 정렬';

  @override
  String get select_current_sentence => '현재 문장 전체 선택';

  @override
  String word_count(int count) {
    return '$count자';
  }

  @override
  String get insert_content => '콘텐츠 삽입';

  @override
  String get text_format => '텍스트 서식';

  @override
  String get more => '더 보기';

  @override
  String get select_tags => '라벨 선택';

  @override
  String get create_tag_first => '먼저 라벨 페이지에서 라벨을 만드세요';

  @override
  String get delete_component_confirm => '이 메모 구성 요소를 삭제할까요?';

  @override
  String get no_text_content => '텍스트 내용이 없습니다';

  @override
  String get no_checklist_items => '체크리스트 항목이 없습니다';

  @override
  String completed_count(int done, int total) {
    return '$done / $total 완료';
  }

  @override
  String get unnamed_checklist_item => '제목 없는 체크리스트 항목';

  @override
  String more_items(int count) {
    return '$count개 더';
  }

  @override
  String get no_drawings => '그림이 없습니다';

  @override
  String get no_images => '이미지가 없습니다';

  @override
  String get image_load_failed => '이미지를 불러올 수 없습니다';

  @override
  String get no_recording => '녹음이 없습니다';

  @override
  String get recorded_tap_to_play => '녹음됨, 탭하여 재생';

  @override
  String get note_archive => '메모 보관함';

  @override
  String get no_archived_notes => '보관된 메모가 없습니다';

  @override
  String get no_text_content_short => '텍스트 없음';

  @override
  String get restore => '복원';

  @override
  String get momotalk_archive => 'MomoTalk 보관함';

  @override
  String get no_archived_chats => '보관된 대화가 없습니다';

  @override
  String get exit_unsaved_title => '저장되지 않은 변경 사항';

  @override
  String get exit_unsaved_message => '저장되지 않은 변경 사항이 있습니다. 저장하고 나갈까요?';

  @override
  String get discard => '버리기';

  @override
  String get right_swipe_action => '오른쪽 스와이프 동작';

  @override
  String get left_swipe_action => '왼쪽 스와이프 동작';

  @override
  String get gesture_pin => '고정';

  @override
  String get gesture_archive => '보관';

  @override
  String get gesture_mark => '표시';

  @override
  String image_send_failed(String error) {
    return '이미지 전송 실패: $error';
  }

  @override
  String get gallery_load_failed => '일러스트 차분 로드 실패';

  @override
  String get gallery_not_found => '이 학생의 일러스트 차분을 찾을 수 없습니다';

  @override
  String get portrait_variants => '일러스트 차분';

  @override
  String get screenshot_failed => '스크린샷 실패';

  @override
  String get message_reorder => '순서 변경';

  @override
  String get message_edit => '변경';

  @override
  String get message_transform => '변환';

  @override
  String get transform_developing => '변환 기능 준비 중';

  @override
  String get edit_message => '메시지 변경';

  @override
  String get enter_new_message => '새 메시지 내용 입력';

  @override
  String get not_enough_messages => '순서를 바꿀 메시지가 부족합니다';

  @override
  String get drag_to_reorder => '메시지를 끌어 순서 변경';

  @override
  String get switch_student => '학생 전환';

  @override
  String get emoji => '이모지';

  @override
  String get image => '이미지';

  @override
  String get student => '학생';

  @override
  String get send_as_student => '학생으로 보내기';

  @override
  String get send_as_teacher => '선생님으로 보내기';

  @override
  String get screenshot => '스크린샷';

  @override
  String get current_identity_student => '현재 학생으로 전송 중';

  @override
  String get current_identity_teacher => '현재 선생님으로 전송 중';

  @override
  String get gallery => '갤러리';

  @override
  String get stroke_width => '선 굵기';

  @override
  String get undo => '실행 취소';

  @override
  String get redo => '다시 실행';

  @override
  String get drawing_eraser => '지우개';

  @override
  String get drawing_highlighter => '형광펜';

  @override
  String get drawing_pencil => '연필';

  @override
  String get drawing_marker => '마커';

  @override
  String get version => '버전';

  @override
  String get developer => '개발자';

  @override
  String get open_source_license => '오픈 소스 라이선스';

  @override
  String get clear_drawing_confirm => '그림을 지울까요?';

  @override
  String get custom_color => '사용자 지정 색상';

  @override
  String get search_students => '학생 검색';

  @override
  String get no_student_matches => '일치하는 학생이 없습니다';

  @override
  String get ai_image_model_warning => '이 모델은 이미지 입력을 지원하지 않을 수 있습니다. 이미지 인식에는 비전 지원 모델로 전환하세요.';

  @override
  String get select_all_document => '전체 텍스트 선택';

  @override
  String get copy_all_text => '전체 텍스트 복사';

  @override
  String get all_text_copied => '전체 텍스트를 복사했습니다';

  @override
  String get move_canvas => '캔버스 이동';

  @override
  String get center_canvas => '캔버스 가운데';

  @override
  String get zoom_in => '확대';

  @override
  String get zoom_out => '축소';

  @override
  String get canvas_background => '캔버스 배경';

  @override
  String get canvas_style_grid => '격자';

  @override
  String get canvas_style_dots => '점선';

  @override
  String get canvas_style_none => '배경 없음';

  @override
  String ai_conversation_save_failed(String error) {
    return '대화를 저장하지 못했습니다: $error';
  }

  @override
  String get save_failed_retrying => '저장하지 못했습니다. 변경 사항은 유지되며 다시 시도합니다.';

  @override
  String get recovery_draft_found => '저장되지 않은 초안이 있습니다';

  @override
  String get recovery_draft_message => '이전 편집에서 남은 복구 초안이 있습니다. 복원할까요?';

  @override
  String get open_menu => '메뉴 열기';

  @override
  String get theme_system => '시스템';

  @override
  String get theme_light => '라이트';

  @override
  String get theme_dark => '다크';

  @override
  String get search_notes => '노트 검색';

  @override
  String get search_notes_hint => '제목, 내용 및 태그 검색';

  @override
  String get search_empty_title => '검색어를 입력하세요';

  @override
  String get search_empty_message => '제목, 본문, 체크리스트 항목 및 태그를 검색합니다.';

  @override
  String get search_no_results_title => '일치하는 노트가 없습니다';

  @override
  String get search_no_results_message => '더 짧은 검색어를 사용하거나 태그 필터를 제거하세요.';

  @override
  String get search_clear => '검색 지우기';

  @override
  String get untitled => '제목 없음';

  @override
  String search_results_count(int count) {
    return '$count개 결과';
  }

  @override
  String get copy_reply => '답글 복사';

  @override
  String get regenerate_reply => '다시 생성';

  @override
  String get reply_copied => '답글을 복사했습니다';

  @override
  String get copy_reply_failed => '답글을 복사하지 못했습니다';

  @override
  String get export_markdown => '노트를 Markdown으로 복사';

  @override
  String get export_markdown_subtitle => '모든 활성 노트를 클립보드에 복사';

  @override
  String get export_backup => 'JSON 백업 저장';

  @override
  String get export_backup_subtitle => '노트, 태그, 채팅 및 AI 대화 저장';

  @override
  String get export_markdown_done => '노트를 클립보드에 복사했습니다';

  @override
  String export_backup_saved(String path) {
    return '백업을 $path에 저장했습니다';
  }

  @override
  String export_failed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String get add_text_component => '텍스트 구성 요소 추가';

  @override
  String get message_actions => '메시지 작업';

  @override
  String get copy => '복사';

  @override
  String get select_text => '텍스트 선택';

  @override
  String get delete_message_confirm => '이 메시지를 삭제할까요?';

  @override
  String get delete_message_body => '이 메시지가 대화에서 제거됩니다.';

  @override
  String get regenerate_confirm => '이 답글을 다시 생성할까요?';

  @override
  String get remove_following_messages => '컨텍스트가 변경되므로 이 답글 이후의 메시지가 삭제됩니다.';

  @override
  String get edit_message_hint => '메시지 텍스트 편집';

  @override
  String get about_tagline => '메모와 아이디어, 대화를 차분히 담는 공간.';
}
