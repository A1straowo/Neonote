// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get note => 'Nota';

  @override
  String get label => 'Etiqueta';

  @override
  String get motalk => 'MomoTalk';

  @override
  String get settings => 'Ajustes';

  @override
  String get general => 'General';

  @override
  String get language => 'Idioma';

  @override
  String get dark_theme => 'Tema oscuro';

  @override
  String get the_quick_brown_fox_jumps_over_the_lazy_dog => 'El zorro marrón rápido salta sobre el perro perezoso';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get title => 'Título';

  @override
  String get quit => '¿Guardar y salir?';

  @override
  String get size => 'Escala';

  @override
  String get normal => 'Predeterminado';

  @override
  String get theme => 'Tema';

  @override
  String get color_scheme => 'Esquema de color';

  @override
  String get default_color_scheme => 'Colores predeterminados';

  @override
  String get optimize_storage => 'Optimizar almacenamiento';

  @override
  String get optimize_storage_subtitle => 'Elimina multimedia sin usar y compacta la base de datos local';

  @override
  String get optimize_storage_confirm => '¿Eliminar archivos multimedia sin referencia, copias de exportación antiguas y compactar la base de datos? Las notas se conservan.';

  @override
  String optimize_storage_done(String size) {
    return 'Se liberaron $size';
  }

  @override
  String get message_student => 'Estudiante';

  @override
  String get message_teacher => 'Maestra(o)';

  @override
  String get message => 'Mensaje';

  @override
  String get custom => 'Personalizado';

  @override
  String get character => 'Estudiante';

  @override
  String get clear_failed => 'Error al borrar!';

  @override
  String get clear_config => 'Borrar configuración';

  @override
  String get clear_cache => 'Borrar caché';

  @override
  String get auto_save => 'Autoguardado';

  @override
  String get dialog => 'Diálogo';

  @override
  String get font => 'Fuente';

  @override
  String get radius => 'Radio';

  @override
  String get settings_saved => 'Ajustes guardados!';

  @override
  String get apply => 'Aplicar cambios';

  @override
  String get restore_defaults => 'Restaurar valores predeterminados';

  @override
  String get restore_confirm => '¿Restaurar todos los ajustes a los valores predeterminados?';

  @override
  String get defaults_restored => 'Valores predeterminados restaurados';

  @override
  String get show_student_surname => 'Mostrar apellido';

  @override
  String get reverse_name => 'Invertir nombre';

  @override
  String get student_name_language => 'Idioma del nombre';

  @override
  String get language_chinese => 'Chino';

  @override
  String get language_japanese => 'Japonés';

  @override
  String get language_english => 'Inglés';

  @override
  String get language_korean => 'Coreano';

  @override
  String get language_spanish => 'Español';

  @override
  String get language_russian => 'Ruso';

  @override
  String get remark => 'Observación';

  @override
  String get teacher_avatar => 'Avatar del profesor';

  @override
  String get custom_student => 'Estudiante personalizado';

  @override
  String get custom_greeting => 'Saludo personalizado';

  @override
  String get interface => 'Interfaz';

  @override
  String get gesture => 'Gestos';

  @override
  String get storage => 'Almacenamiento';

  @override
  String get about => 'Acerca de';

  @override
  String get archive_swipe => 'Archivar (deslizar derecha)';

  @override
  String get delete_swipe => 'Eliminar (deslizar izquierda)';

  @override
  String get select_student => 'Seleccionar estudiante';

  @override
  String get built_in => 'Integrado';

  @override
  String get add_custom_student => 'Añadir estudiante personalizado';

  @override
  String get id => 'ID';

  @override
  String get student_name => 'Nombre';

  @override
  String get no_custom_students => 'No hay estudiantes personalizados';

  @override
  String get delete => 'Eliminar';

  @override
  String get retry => 'Reintentar';

  @override
  String get component_text => 'Texto';

  @override
  String get component_checklist => 'Lista';

  @override
  String get component_drawing => 'Dibujo';

  @override
  String get component_image => 'Imagen';

  @override
  String get component_audio => 'Audio';

  @override
  String get component_delete => 'Eliminar componente';

  @override
  String component_added(String name) {
    return 'Componente $name añadido';
  }

  @override
  String get checklist_add_item => 'Añadir elemento';

  @override
  String get clear => 'Borrar';

  @override
  String get image_url => 'URL de imagen';

  @override
  String get new_group => 'Nuevo grupo';

  @override
  String get new_chat => 'Nuevo chat';

  @override
  String get group_create => 'Crear grupo';

  @override
  String group_added(String name) {
    return 'Grupo «$name» añadido';
  }

  @override
  String chat_added(String name) {
    return 'Chat «$name» añadido';
  }

  @override
  String group_delete_confirm(String name) {
    return '¿Eliminar el grupo «$name» y todos sus chats?';
  }

  @override
  String chat_delete_confirm(String name) {
    return '¿Eliminar el chat con «$name»?';
  }

  @override
  String get input_name_hint => 'Escribe un nombre…';

  @override
  String get name_required => 'El nombre no puede estar vacío';

  @override
  String get add => 'Añadir';

  @override
  String get rename => 'Cambiar nombre';

  @override
  String get default_group => 'Grupo predeterminado';

  @override
  String get no_chats_in_group => 'Sin conversaciones';

  @override
  String get no_messages => 'Sin mensajes';

  @override
  String get message_hint => 'Escribe un mensaje…';

  @override
  String get send => 'Enviar';

  @override
  String get tag_create => 'Crear nueva etiqueta';

  @override
  String tag_added(String name) {
    return 'Etiqueta «$name» añadida';
  }

  @override
  String get tag_rename => 'Cambiar el nombre de la etiqueta';

  @override
  String tag_delete_confirm(String name) {
    return '¿Eliminar la etiqueta «$name»?';
  }

  @override
  String get storage_used => 'Almacenamiento usado';

  @override
  String get cache_used => 'Caché usada';

  @override
  String get calculating => 'Calculando';

  @override
  String get refresh => 'Actualizar';

  @override
  String get clear_cache_confirm => 'Borrar la caché? Tus notas se conservan.';

  @override
  String get clear_config_confirm => 'Borrar la configuración? Todo volverá a los valores predeterminados.';

  @override
  String get clear_success => 'Borrado';

  @override
  String get pick_from_gallery => 'Elegir de la galería';

  @override
  String get image_pick_failed => 'No se pudo abrir la galería';

  @override
  String get edit_remark => 'Editar observación';

  @override
  String get remark_hint => 'Escribe una observación';

  @override
  String get edit_greeting => 'Editar saludo';

  @override
  String get greeting_hint => 'Escribe un saludo';

  @override
  String get recording => 'Grabando';

  @override
  String get record_audio => 'Grabar audio';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausar';

  @override
  String get record_failed => 'Error al grabar';

  @override
  String get mic_permission_denied => 'Se necesita permiso de micrófono';

  @override
  String get audio_unsupported => 'Esta plataforma no admite grabación';

  @override
  String get add_image => 'Añadir imagen';

  @override
  String get take_photo => 'Tomar foto';

  @override
  String get content_hint => 'Nota';

  @override
  String get deepseek_harness => 'DeepSeek';

  @override
  String get deepseek_enable => 'Activar IA';

  @override
  String get deepseek_api_key => 'Clave API';

  @override
  String get deepseek_base_url => 'URL base';

  @override
  String get deepseek_model => 'Modelo';

  @override
  String get deepseek_system_prompt => 'Indicación del sistema';

  @override
  String get deepseek_test_connection => 'Probar conexión';

  @override
  String get deepseek_testing => 'Probando';

  @override
  String get deepseek_connected => 'Conectado';

  @override
  String get deepseek_connection_failed => 'Error de conexión';

  @override
  String get deepseek_not_configured => 'Configura primero la clave API';

  @override
  String get deepseek_saved => 'Ajustes de DeepSeek guardados';

  @override
  String get ai_chat => 'DeepSeek';

  @override
  String get ai_assistant => 'DeepSeek';

  @override
  String get ai_input_hint => 'Pregunta a la IA';

  @override
  String get ai_thinking => 'Pensando';

  @override
  String get ai_typing => 'Escribiendo';

  @override
  String get ai_error => 'Error de IA';

  @override
  String get ai_insert_note => 'Insertar en notas';

  @override
  String get ai_inserted_to_note => 'Insertado en notas';

  @override
  String get ai_welcome => 'Pregúntame lo que quieras. También puedo ayudarte a escribir notas.';

  @override
  String get deepseek_disabled => 'La IA está desactivada';

  @override
  String get ai_new_conversation_title => 'Nueva conversación';

  @override
  String get ai_wait_reply => 'Espera a que termine la respuesta actual';

  @override
  String get ai_conversation_created => 'Nueva conversación creada';

  @override
  String get ai_mode_minimal => 'Modo mínimo';

  @override
  String get ai_mode_standard => 'Modo estándar';

  @override
  String get ai_reasoning_low => 'Razonamiento: bajo';

  @override
  String get ai_reasoning_medium => 'Razonamiento: medio';

  @override
  String get ai_reasoning_high => 'Razonamiento: alto';

  @override
  String get close_image_preview => 'Cerrar vista previa de imagen';

  @override
  String get close => 'Cerrar';

  @override
  String get ai_image_added => 'Imagen añadida. DeepSeek la reconocerá al enviarla.';

  @override
  String get stop_recording => 'Detener grabación';

  @override
  String get voice => 'Voz';

  @override
  String get ai_image_placeholder => '[Imagen]';

  @override
  String get ai_voice_placeholder => '[Voz]';

  @override
  String get ai_voice_attached => '[El usuario adjuntó voz]';

  @override
  String get ai_new_conversation => 'Nueva conversación';

  @override
  String get ai_history => 'Historial';

  @override
  String ai_voice_count(int count) {
    return 'Voz $count';
  }

  @override
  String get ai_recognizing_image => 'DeepSeek está reconociendo la imagen…';

  @override
  String get ai_empty_conversation => 'Conversación vacía';

  @override
  String get ai_delete_conversation => 'Eliminar conversación';

  @override
  String get ai_search_history => 'Buscar conversaciones';

  @override
  String get ai_no_history => 'No hay historial de conversaciones';

  @override
  String get ai_no_history_match => 'No hay conversaciones coincidentes';

  @override
  String get close_menu => 'Cerrar menú';

  @override
  String get note_blank_deleted => 'Nota vacía eliminada automáticamente';

  @override
  String get note_discarded => 'Nota descartada y eliminada';

  @override
  String get select_sentence_first => 'Selecciona una frase primero';

  @override
  String get text_color => 'Color del texto';

  @override
  String get current_sentence_only => 'Solo se aplica a la frase actual';

  @override
  String get apply_label => 'Aplicar';

  @override
  String get choose_background => 'Elegir fondo';

  @override
  String get solid_background => 'Fondo de color';

  @override
  String get apply_solid_color => 'Aplicar color';

  @override
  String get no_background => 'Sin fondo';

  @override
  String get grid_background => 'Fondo de cuadrícula';

  @override
  String get square_grid => 'Cuadrados';

  @override
  String get dot_grid => 'Puntos';

  @override
  String get horizontal_lines => 'Líneas horizontales';

  @override
  String get image_background => 'Fondo de imagen';

  @override
  String get change_image => 'Cambiar imagen';

  @override
  String get crop_again => 'Recortar de nuevo';

  @override
  String get remove_image_background => 'Quitar fondo de imagen';

  @override
  String get background_image_missing => 'No se encontró la imagen de fondo';

  @override
  String get cannot_read_background => 'No se pudo leer la imagen de fondo';

  @override
  String get crop_background => 'Recortar imagen de fondo';

  @override
  String get crop_top => 'Arriba';

  @override
  String get crop_middle => 'Centro';

  @override
  String get crop_bottom => 'Abajo';

  @override
  String get zoom => 'Zoom';

  @override
  String get crop_hint => 'La imagen llena la nota automáticamente; recorta para ajustar el área focal.';

  @override
  String get use_original => 'Usar original';

  @override
  String get finish_crop => 'Terminar recorte';

  @override
  String crop_failed(String error) {
    return 'Error al recortar: $error';
  }

  @override
  String get checklist_item_hint => 'Elemento de lista';

  @override
  String get insert_checklist_item => 'Insertar elemento de lista';

  @override
  String get insert_divider => 'Insertar separador';

  @override
  String get insert_current_time => 'Insertar hora actual';

  @override
  String get body_text => 'Cuerpo';

  @override
  String get bold => 'Negrita';

  @override
  String get italic => 'Cursiva';

  @override
  String get underline => 'Subrayado';

  @override
  String get strikethrough => 'Tachado';

  @override
  String get align_left => 'Alinear a la izquierda';

  @override
  String get align_center => 'Centrar';

  @override
  String get align_right => 'Alinear a la derecha';

  @override
  String get select_current_sentence => 'Seleccionar frase actual';

  @override
  String word_count(int count) {
    return '$count caracteres';
  }

  @override
  String get insert_content => 'Insertar contenido';

  @override
  String get text_format => 'Formato de texto';

  @override
  String get more => 'Más';

  @override
  String get select_tags => 'Seleccionar etiquetas';

  @override
  String get create_tag_first => 'Primero crea una etiqueta en la página Etiquetas';

  @override
  String get delete_component_confirm => '¿Eliminar este componente de nota?';

  @override
  String get no_text_content => 'Sin contenido de texto';

  @override
  String get no_checklist_items => 'No hay elementos de lista';

  @override
  String completed_count(int done, int total) {
    return '$done / $total completados';
  }

  @override
  String get unnamed_checklist_item => 'Elemento de lista sin título';

  @override
  String more_items(int count) {
    return '$count más';
  }

  @override
  String get no_drawings => 'Sin dibujos';

  @override
  String get no_images => 'Sin imágenes';

  @override
  String get image_load_failed => 'No se pudo cargar la imagen';

  @override
  String get no_recording => 'Sin grabación';

  @override
  String get recorded_tap_to_play => 'Grabado, toca para reproducir';

  @override
  String get note_archive => 'Archivo de notas';

  @override
  String get no_archived_notes => 'No hay notas archivadas';

  @override
  String get no_text_content_short => 'Sin texto';

  @override
  String get restore => 'Restaurar';

  @override
  String get momotalk_archive => 'Archivo de MomoTalk';

  @override
  String get no_archived_chats => 'No hay conversaciones archivadas';

  @override
  String get exit_unsaved_title => 'Cambios sin guardar';

  @override
  String get exit_unsaved_message => 'Se detectaron cambios sin guardar. ¿Guardar antes de salir?';

  @override
  String get discard => 'Descartar';

  @override
  String get right_swipe_action => 'Acción al deslizar a la derecha';

  @override
  String get left_swipe_action => 'Acción al deslizar a la izquierda';

  @override
  String get gesture_pin => 'Fijar';

  @override
  String get gesture_archive => 'Archivar';

  @override
  String get gesture_mark => 'Marcar';

  @override
  String image_send_failed(String error) {
    return 'Error al enviar la imagen: $error';
  }

  @override
  String get gallery_load_failed => 'No se pudo cargar la galería de retratos';

  @override
  String get gallery_not_found => 'No se encontraron variantes de retrato para este estudiante';

  @override
  String get portrait_variants => 'Variantes de retrato';

  @override
  String get screenshot_failed => 'Error de captura de pantalla';

  @override
  String get message_reorder => 'Reordenar';

  @override
  String get message_edit => 'Editar';

  @override
  String get message_transform => 'Transformar';

  @override
  String get transform_developing => 'La función de transformación estará disponible pronto';

  @override
  String get edit_message => 'Editar mensaje';

  @override
  String get enter_new_message => 'Introduce el nuevo mensaje';

  @override
  String get not_enough_messages => 'No hay suficientes mensajes para reordenar';

  @override
  String get drag_to_reorder => 'Arrastra los mensajes para reordenar';

  @override
  String get switch_student => 'Cambiar estudiante';

  @override
  String get emoji => 'Emoji';

  @override
  String get image => 'Imagen';

  @override
  String get student => 'Estudiante';

  @override
  String get send_as_student => 'Enviar como estudiante';

  @override
  String get send_as_teacher => 'Enviar como profesor';

  @override
  String get screenshot => 'Captura de pantalla';

  @override
  String get current_identity_student => 'Ahora envías como estudiante';

  @override
  String get current_identity_teacher => 'Ahora envías como profesor';

  @override
  String get gallery => 'Galería';

  @override
  String get stroke_width => 'Grosor del trazo';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Rehacer';

  @override
  String get drawing_eraser => 'Borrador';

  @override
  String get drawing_highlighter => 'Resaltador';

  @override
  String get drawing_pencil => 'Lápiz';

  @override
  String get drawing_marker => 'Rotulador';

  @override
  String get version => 'Versión';

  @override
  String get developer => 'Desarrollador';

  @override
  String get open_source_license => 'Licencia de código abierto';

  @override
  String get clear_drawing_confirm => '¿Borrar el dibujo?';

  @override
  String get custom_color => 'Color personalizado';

  @override
  String get search_students => 'Buscar estudiantes';

  @override
  String get no_student_matches => 'No hay estudiantes coincidentes';

  @override
  String get ai_image_model_warning => 'Este modelo puede no admitir imágenes. Cambia a un modelo con visión para reconocerlas.';

  @override
  String get select_all_document => 'Seleccionar todo el texto';

  @override
  String get copy_all_text => 'Copiar todo el texto';

  @override
  String get all_text_copied => 'Todo el texto copiado';

  @override
  String get move_canvas => 'Mover lienzo';

  @override
  String get center_canvas => 'Centrar lienzo';

  @override
  String get zoom_in => 'Acercar';

  @override
  String get zoom_out => 'Alejar';

  @override
  String get canvas_background => 'Fondo del lienzo';

  @override
  String get canvas_style_grid => 'Cuadrícula';

  @override
  String get canvas_style_dots => 'Puntos';

  @override
  String get canvas_style_none => 'Sin fondo';

  @override
  String ai_conversation_save_failed(String error) {
    return 'No se pudo guardar la conversación: $error';
  }

  @override
  String get save_failed_retrying => 'No se pudo guardar. Los cambios se conservan y se reintentarán.';

  @override
  String get recovery_draft_found => 'Se encontró un borrador sin guardar';

  @override
  String get recovery_draft_message => 'Hay un borrador de recuperación de la sesión anterior. ¿Restaurarlo?';

  @override
  String get open_menu => 'Abrir menú';

  @override
  String get theme_system => 'Sistema';

  @override
  String get theme_light => 'Claro';

  @override
  String get theme_dark => 'Oscuro';

  @override
  String get search_notes => 'Buscar notas';

  @override
  String get search_notes_hint => 'Buscar títulos, contenido y etiquetas';

  @override
  String get search_empty_title => 'Escribe para buscar';

  @override
  String get search_empty_message => 'Busca títulos, texto, elementos de lista y etiquetas.';

  @override
  String get search_no_results_title => 'No hay notas coincidentes';

  @override
  String get search_no_results_message => 'Prueba una palabra más corta o quita el filtro de etiqueta.';

  @override
  String get search_clear => 'Borrar búsqueda';

  @override
  String get untitled => 'Sin título';

  @override
  String search_results_count(int count) {
    return '$count resultado(s)';
  }

  @override
  String get copy_reply => 'Copiar respuesta';

  @override
  String get regenerate_reply => 'Regenerar';

  @override
  String get reply_copied => 'Respuesta copiada';

  @override
  String get copy_reply_failed => 'No se pudo copiar la respuesta';

  @override
  String get export_markdown => 'Copiar notas como Markdown';

  @override
  String get export_markdown_subtitle => 'Copiar todas las notas activas al portapapeles';

  @override
  String get export_backup => 'Guardar copia JSON';

  @override
  String get export_backup_subtitle => 'Guardar notas, etiquetas, chats y conversaciones de IA';

  @override
  String get export_markdown_done => 'Notas copiadas al portapapeles';

  @override
  String export_backup_saved(String path) {
    return 'Copia guardada en $path';
  }

  @override
  String export_failed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get add_text_component => 'Añadir componente de texto';

  @override
  String get message_actions => 'Acciones del mensaje';

  @override
  String get copy => 'Copiar';

  @override
  String get select_text => 'Seleccionar texto';

  @override
  String get delete_message_confirm => '¿Eliminar este mensaje?';

  @override
  String get delete_message_body => 'Este mensaje se eliminará de la conversación.';

  @override
  String get regenerate_confirm => '¿Regenerar esta respuesta?';

  @override
  String get remove_following_messages => 'Los mensajes posteriores a esta respuesta se eliminarán porque cambia el contexto.';

  @override
  String get edit_message_hint => 'Editar el texto del mensaje';

  @override
  String get about_tagline => 'Un lugar tranquilo para notas, ideas y conversaciones.';
}
