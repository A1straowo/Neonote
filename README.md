<div align="center">

<img src="assets/icon/app_icon.png" width="116" alt="Neonote app icon" />

# Neonote

**A quiet place for notes, ideas and conversations.**

Local-first note-taking, a MomoTalk-inspired character chat space, and optional DeepSeek AI — in one Flutter app.

[![Latest release](https://img.shields.io/github/v/release/A1straowo/Neonote?display_name=tag&sort=semver)](https://github.com/A1straowo/Neonote/releases/latest)
[![Android](https://img.shields.io/badge/platform-Android-3DDC84?logo=android&logoColor=white)](#download)
[![Flutter](https://img.shields.io/badge/built%20with-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

[English](#english) · [简体中文](#简体中文) · [日本語](#日本語) · [한국어](#한국어) · [Español](#español) · [Русский](#русский)

[Download](#download) · [Features](#features) · [Build from source](#build-from-source) · [FAQ](#faq)

</div>

---

> [!IMPORTANT]
> **Download mirror:** If `github.com` is slow or unavailable in your network, use the official GitHub Pages mirror: **<https://a1straowo.github.io/Neonote/>**<br>
> Direct APK links and SHA-256 checksums are available in the [download section](#download).

> [!NOTE]
> The current APKs are signed with the Android **debug key** for testing. They can be installed directly, but production distributions should be re-signed with a private release keystore.

## At a glance

- **Local-first:** notes, tags, chats, attachments and AI conversation history stay in the app's local storage.
- **One workspace:** rich notes, drawing, checklists, images, audio, full-text search, archive and recovery drafts.
- **MomoTalk-inspired chats:** student/teacher dialogue, portrait galleries, message editing/reordering and screenshots.
- **Optional AI:** connect your own DeepSeek-compatible endpoint, chat with images/voice attachments, and insert replies into notes.
- **Made to last:** Material 3 theming, six UI languages, adaptive layouts, storage cleanup and a reproducible GitHub Actions release pipeline.

---

<a id="english"></a>

## English

### Overview

Neonote is an Android-first, local-first creative workspace built with Flutter. It combines a flexible note editor, a drawing canvas, a MomoTalk-style chat playground and an optional DeepSeek AI assistant. There is no account system and no mandatory cloud service: the app opens as a private notebook and only talks to the network when you explicitly use an AI feature.

The project is useful if you want a single place for short notes, long-form drafts, sketches, checklists and character-style conversations — without tying your data to a proprietary note cloud.

### Features

#### Notes and personal knowledge

- Rich text blocks with headings, bold, italic, underline, strikethrough, alignment and sentence-level text color.
- Checklists with completion counts, dividers, current-time insertion and multi-block editing.
- Drawing canvas with pencil, marker, highlighter, eraser, stroke width, undo/redo, zoom and grid/dot backgrounds.
- Image notes with gallery/camera import, embedded media, image backgrounds and crop controls.
- Audio recording and playback inside notes.
- Labels/tags, full-text search across titles, body text, checklist items and tags, plus an archive.
- Autosave, save-on-background, unsaved-change prompts and local recovery drafts.
- Note card backgrounds: solid color, square grid, dot grid, horizontal lines or a cropped image.

#### MomoTalk-inspired chat

- Student groups, custom groups and custom students.
- Send messages as either the student or the teacher.
- Student portrait gallery, avatar/remark/greeting customization and name-display preferences.
- Message editing, reordering, screenshots and per-message actions.
- Pin, mark, archive and delete chats; swipe actions are configurable.
- The conversation view is intentionally a local creative tool, not a real messaging service.

#### DeepSeek AI

- Bring your own DeepSeek API key and optional OpenAI-compatible base URL/model.
- Test the connection from the settings page; configure a system prompt.
- Multi-turn conversations with history search and conversation deletion.
- Standard/minimal modes and low/medium/high reasoning controls.
- Attach images or voice files; image understanding depends on the selected model.
- Markdown replies with copy, select text, edit, delete, regenerate and insert-into-note actions.
- API requests go only to the endpoint you configure.

#### Personalization and accessibility

- Material 3 design with light, dark and system modes.
- Default, MomoTalk and custom color palettes.
- Adjustable text scale, adaptive dialogs/sheets and responsive content widths.
- UI localization: English, Simplified Chinese, Japanese, Korean, Spanish and Russian.
- Storage dashboard with cache cleanup and an explicit optimize-storage action.

### Download

The latest version is **v1.0.4**.

| Build | Recommended for | GitHub release | Backup mirror |
| --- | --- | --- | --- |
| `arm64-v8a` | Most modern Android phones | [Download](https://github.com/A1straowo/Neonote/releases/download/v1.0.4/Neonote-1.0.4-arm64-v8a.apk) | [Mirror](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-arm64-v8a.apk) |
| `armeabi-v7a` | Older 32-bit Android devices | [Download](https://github.com/A1straowo/Neonote/releases/download/v1.0.4/Neonote-1.0.4-armeabi-v7a.apk) | [Mirror](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-armeabi-v7a.apk) |
| `x86_64` | Android emulators and x86_64 devices | [Download](https://github.com/A1straowo/Neonote/releases/download/v1.0.4/Neonote-1.0.4-x86_64.apk) | [Mirror](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-x86_64.apk) |
| `universal` | Compatibility fallback (largest file) | [Download](https://github.com/A1straowo/Neonote/releases/download/v1.0.4/Neonote-1.0.4-universal.apk) | [Mirror](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-universal.apk) |

**All downloads:** [GitHub Releases](https://github.com/A1straowo/Neonote/releases/latest) · [Backup mirror](https://a1straowo.github.io/Neonote/) · [Checksums](https://a1straowo.github.io/Neonote/SHA256SUMS.txt)

<details>
<summary><strong>SHA-256 checksums for v1.0.4</strong></summary>

The GitHub release and the backup mirror were packaged separately, so they use different file names and have different checksums. Verify the file you actually downloaded against the matching list below.

**GitHub Releases (`Neonote-1.0.4-...`)**

```text
93b21eb9a3481fe932de17844e0908e8baed20c610af230a80731eea0c1f0ef5  Neonote-1.0.4-arm64-v8a.apk
1423f2afcd1d54509122a659f40a31cc75f7dc50724d221ef7ae93d0410b9323  Neonote-1.0.4-armeabi-v7a.apk
5e47965b44f5c6d6c0b8b36254d53fc335badc5b64b96241923bd85e289d0391  Neonote-1.0.4-x86_64.apk
2ca08a7aa2a57a3c49df019aeee9497c1f481f5cf7a1da525b00499fda4811d2  Neonote-1.0.4-universal.apk
```

**GitHub Pages mirror (`Neonote-v1.0.4-...`)**

```text
2fc6d73d51a59b9f657dccf4d94eccc31a1f0a12ac549cff499904ba9318d15d  Neonote-v1.0.4-arm64-v8a.apk
edb755b75b0464b280677b17cb0adfdf56d8866fe1a11b97e1f67d80602fa892  Neonote-v1.0.4-armeabi-v7a.apk
ea62d89f4af97f41193fde2c68b0a65a03e553180a5c07b56dcf021477683b65  Neonote-v1.0.4-x86_64.apk
5c57a8edeaa121fdd978d1b5887c25c28e78a597c5d5b1f83ec7bd2828a68192  Neonote-v1.0.4-universal.apk
```

</details>

### Install

1. Download the APK that matches your device. If unsure, choose `arm64-v8a` for a modern phone or `universal` for maximum compatibility.
2. Allow installation from your browser/file manager when Android asks. The current test builds are debug-signed, so Play Protect may show a warning.
3. Open the APK and install it.
4. Optional: install through ADB with `adb install -r Neonote-1.0.4-arm64-v8a.apk`.

Minimum Android version is `minSdk 24` (Android 7.0+); the current release targets Android 16 / API 36.

### Configure AI

1. Open **Settings → DeepSeek**.
2. Enter your API key. If needed, change the base URL and model name.
3. Press **Test connection**, then save.
4. Open the DeepSeek screen from the home page to start a conversation.

Your key is stored in the app's local configuration. It is not committed to this repository and is not uploaded anywhere by Neonote; AI requests go to the endpoint you configure. The app currently uses local Hive storage rather than hardware-backed secure storage, so avoid using a production secret on a shared device.

### Build from source

#### Requirements

- Flutter 3.47.x (Dart 3.13+) — the release workflow pins Flutter `3.47.5`.
- JDK 21 (the JBR bundled with Android Studio works).
- Android SDK Platform 36 and Build Tools 36.x.
- An Android device or emulator for testing.

Configure `android/local.properties` for your machine:

```properties
sdk.dir=/path/to/Android/Sdk
flutter.sdk=/path/to/flutter
```

Then build:

```bash
git clone https://github.com/A1straowo/Neonote.git
cd Neonote
flutter pub get
flutter run                 # debug on a connected device/emulator
flutter test                # unit and widget tests
flutter build apk --release # universal APK
```

For smaller per-ABI builds:

```bash
flutter build apk --release --split-per-abi
```

Outputs:

- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`
- `build/app/outputs/flutter-apk/app-release.apk` (universal)

The GitHub Actions workflow rebuilds all four APKs and `SHA256SUMS.txt` whenever a `v*` tag is pushed.

### Project structure

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | App bootstrap, theme, localization and top-level navigation |
| `lib/workbench.dart` | Note canvas, rich-text blocks, drawing and media workspaces |
| `lib/note_editor.dart` | Note editing shell and component actions |
| `lib/store/note_store.dart` | Local notes, tags, chats and conversations |
| `lib/search/` | Full-text note search |
| `lib/deepseek/` | DeepSeek chat UI, message actions and settings |
| `lib/services/deepseek_service.dart` | OpenAI-compatible DeepSeek client |
| `lib/momotalk/` | MomoTalk-style home, chat and character screens |
| `lib/momotalk/mochar.dart` | Teacher/student profile settings |
| `lib/services/` | Storage, media, export and platform services |
| `lib/ui/` | Adaptive layout, theme, device scaling and canvas painters |
| `lib/l10n/` | ARB localizations for six languages |
| `test/` | Unit, widget, storage and performance smoke tests |
| `.github/workflows/android-release.yml` | Tag-driven APK build and release |

### Tech stack

Flutter · Dart · Material 3 · Hive · sqflite · Provider · `http` · `image` · `path_provider` · Android Gradle/Kotlin

### Engineering notes

- Note list rebuilds use cached normalized maps and domain-specific notifications to avoid repeated deep parsing.
- Text undo snapshots are debounced and bounded in both entry count and approximate payload size.
- Drawing input is frame-coalesced; completed strokes are simplified and live/finished layers use separate repaint boundaries.
- The grid/dot canvas uses cached geometry and an `ImageShader` tile rather than drawing thousands of individual dots.
- Images are decoded near display resolution and the global image cache is capped.
- Android backup is disabled so local notes, chats and API configuration are not copied into device backups.
- AI history, notes and media remain local; only AI requests send the selected conversation content to your endpoint.

### FAQ

**GitHub downloads fail. What should I do?**<br>
Use the [GitHub Pages mirror](https://a1straowo.github.io/Neonote/) or the per-file mirror links above. Compare the downloaded APK against `SHA256SUMS.txt` if you want to verify integrity.

**Is Neonote free?**<br>
The app is MIT-licensed and free to use. DeepSeek/AI usage may be billed by the API provider you choose.

**Does AI work offline?**<br>
No. AI features require network access and a configured API key. Notes and other local features work offline.

**Where is my data stored?**<br>
In the app's private local storage. There is no Neonote account or built-in cross-device sync. Uninstalling the app removes its private data unless the operating system keeps it in a backup.

**Is this an official Blue Archive/MomoTalk app?**<br>
No. MomoTalk is an unofficial, fan-inspired interface style. Neonote is not affiliated with NEXON or Blue Archive.

**Why does Android warn about the APK?**<br>
The current release assets are signed with the standard Android debug key. This is fine for testing, but production builds should use your own private release keystore.

### Contributing

Issues and pull requests are welcome. Please keep changes focused, run `flutter analyze` and `flutter test`, and include screenshots or a short reproduction for UI changes. For release changes, verify both a universal APK and at least one per-ABI build.

### License

Released under the [MIT License](LICENSE). Copyright (c) 2026 A1straowo.

---

<a id="简体中文"></a>

## 简体中文

### 项目简介

Neonote 是一款以 Android 为主、坚持本地优先的 Flutter 创作型笔记应用。它把富文本笔记、手绘画布、MomoTalk 风格的角色聊天练习场和可选的 DeepSeek AI 助手放进同一个应用。没有账号系统，也没有强制云同步：打开就是一本私人笔记本；只有在你主动使用 AI 功能时，应用才会访问网络。

如果你希望把短笔记、长文草稿、草图、待办清单和角色对话放在一个地方，同时不想把数据交给专有笔记云服务，Neonote 就是为此设计的。

### 主要功能

- **笔记与知识管理**：富文本块、标题、加粗/斜体/下划线/删除线、对齐、句级文字颜色、待办清单、分隔线、当前时间插入。
- **绘图和媒体**：铅笔、马克笔、荧光笔、橡皮、笔画粗细、撤销/重做、缩放、网格/点阵背景、图片插入、图片背景裁剪、录音与播放。
- **整理与查找**：标签、标题/正文/清单/标签全文搜索、归档、自动保存、切后台保存、未保存提醒和本地恢复草稿。
- **便签外观**：纯色、方格、点阵、横线或图片背景。
- **MomoTalk 风格聊天**：学生分组、自定义分组/学生、学生与老师身份发送、立绘图库、头像/备注/问候语、消息编辑/排序/截图、置顶/标记/归档/删除和可配置滑动操作。
- **DeepSeek AI**：自定义 API Key、Base URL、模型和系统提示词；连接测试；多轮对话与历史搜索；标准/极简模式；低/中/高推理强度；图片与语音附件；Markdown 回复；复制、选择、编辑、删除、重新生成和插入笔记。
- **个性化与无障碍**：Material 3、浅色/深色/跟随系统、默认/MomoTalk/自定义配色、字体缩放、自适应对话框与内容宽度、六种界面语言。
- **存储维护**：缓存清理、存储统计和显式“优化存储”操作。

### 下载

当前版本：**v1.0.4**。

| 安装包 | 适用设备 | GitHub 官方下载 | 备用镜像 |
| --- | --- | --- | --- |
| `arm64-v8a` | 大多数现代 Android 手机 | [下载](https://github.com/A1straowo/Neonote/releases/download/v1.0.4/Neonote-1.0.4-arm64-v8a.apk) | [镜像](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-arm64-v8a.apk) |
| `armeabi-v7a` | 较老的 32 位 Android 设备 | [下载](https://github.com/A1straowo/Neonote/releases/download/v1.0.4/Neonote-1.0.4-armeabi-v7a.apk) | [镜像](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-armeabi-v7a.apk) |
| `x86_64` | Android 模拟器和 x86_64 设备 | [下载](https://github.com/A1straowo/Neonote/releases/download/v1.0.4/Neonote-1.0.4-x86_64.apk) | [镜像](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-x86_64.apk) |
| `universal` | 通用兼容版（文件最大） | [下载](https://github.com/A1straowo/Neonote/releases/download/v1.0.4/Neonote-1.0.4-universal.apk) | [镜像](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-universal.apk) |

**下载入口：** [GitHub Releases](https://github.com/A1straowo/Neonote/releases/latest) · [GitHub Pages 备用镜像](https://a1straowo.github.io/Neonote/) · [SHA256SUMS.txt](https://a1straowo.github.io/Neonote/SHA256SUMS.txt)

> 如果 `github.com` 打不开或下载很慢，请直接使用 GitHub Pages 镜像。镜像提供与 Release 相同的 APK 和校验文件。

<details>
<summary><strong>v1.0.4 SHA-256 校验值</strong></summary>

GitHub Release 与备用镜像分别打包，文件名和校验值不同。请根据实际下载来源核对对应列表。

**GitHub Release（`Neonote-1.0.4-...`）**

```text
93b21eb9a3481fe932de17844e0908e8baed20c610af230a80731eea0c1f0ef5  Neonote-1.0.4-arm64-v8a.apk
1423f2afcd1d54509122a659f40a31cc75f7dc50724d221ef7ae93d0410b9323  Neonote-1.0.4-armeabi-v7a.apk
5e47965b44f5c6d6c0b8b36254d53fc335badc5b64b96241923bd85e289d0391  Neonote-1.0.4-x86_64.apk
2ca08a7aa2a57a3c49df019aeee9497c1f481f5cf7a1da525b00499fda4811d2  Neonote-1.0.4-universal.apk
```

**GitHub Pages 备用镜像（`Neonote-v1.0.4-...`）**

```text
2fc6d73d51a59b9f657dccf4d94eccc31a1f0a12ac549cff499904ba9318d15d  Neonote-v1.0.4-arm64-v8a.apk
edb755b75b0464b280677b17cb0adfdf56d8866fe1a11b97e1f67d80602fa892  Neonote-v1.0.4-armeabi-v7a.apk
ea62d89f4af97f41193fde2c68b0a65a03e553180a5c07b56dcf021477683b65  Neonote-v1.0.4-x86_64.apk
5c57a8edeaa121fdd978d1b5887c25c28e78a597c5d5b1f83ec7bd2828a68192  Neonote-v1.0.4-universal.apk
```

</details>

### 安装

1. 根据设备架构下载 APK。不确定时优先选 `arm64-v8a`，或使用兼容性最好的 `universal`。
2. 按 Android 提示允许浏览器或文件管理器安装未知来源应用。当前测试包使用 Android 调试证书签名，系统可能显示安全提醒。
3. 打开 APK 完成安装。
4. 也可以使用 ADB：`adb install -r Neonote-1.0.4-arm64-v8a.apk`。

### 配置 AI

1. 打开 **设置 → DeepSeek**。
2. 填入自己的 API Key，必要时修改 Base URL 和模型名。
3. 点击 **测试连接**，确认无误后保存。
4. 从首页进入 DeepSeek 页面即可开始对话。

API Key 只保存在应用的本地配置中，不会提交到本仓库，也不会被 Neonote 上传到其它地方；AI 请求只会发送到你配置的服务地址。目前配置使用本地 Hive 存储而非硬件级安全存储，因此不建议在共用设备上使用生产密钥。

### 从源码构建

环境要求：

- Flutter 3.47.x（Dart 3.13+），发布工作流固定使用 Flutter `3.47.5`。
- JDK 21。
- Android SDK Platform 36 和 Build Tools 36.x。
- 一台 Android 设备或模拟器。

在 `android/local.properties` 中配置本机路径：

```properties
sdk.dir=/path/to/Android/Sdk
flutter.sdk=/path/to/flutter
```

构建命令：

```bash
git clone https://github.com/A1straowo/Neonote.git
cd Neonote
flutter pub get
flutter test
flutter build apk --release
```

按 ABI 拆分的小体积安装包：

```bash
flutter build apk --release --split-per-abi
```

### 数据与隐私

- 笔记、标签、聊天、附件和 AI 对话历史默认保存在本机应用私有目录。
- Android 系统备份已关闭，避免这些数据被自动复制到系统备份。
- 只有使用 AI 时，所选对话内容、附件和 API Key 才会发送到你配置的 AI 服务端。
- 当前没有账号系统、云同步或跨设备同步；卸载应用会删除其私有数据。
- 建议在重要设备上使用自己的 API Key，并为正式分发构建配置私有 release keystore。

### 常见问题

**GitHub 下载失败怎么办？**<br>
使用 [GitHub Pages 镜像](https://a1straowo.github.io/Neonote/) 或上表的单文件镜像。下载后可与 SHA-256 校验值比对。

**应用是否免费？**<br>
源码使用 MIT 协议，应用本身免费；使用 DeepSeek 等服务产生的费用由相应 API 提供商收取。

**离线能用吗？**<br>
笔记、绘图、聊天等本地功能可以离线使用；AI 功能需要联网和有效 API Key。

**为什么安装时出现安全提示？**<br>
当前 Release APK 使用 Android 调试证书签名，便于直接测试。正式发布请使用自己的私有 release keystore 重新签名。

**这是官方 Blue Archive / MomoTalk 应用吗？**<br>
不是。MomoTalk 只是类似风格的本地创意界面，本项目与 NEXON、Blue Archive 没有关联。

### 参与贡献

欢迎提交 Issue 和 Pull Request。请尽量保持改动聚焦，并在提交前运行 `flutter analyze` 和 `flutter test`；涉及界面的改动请附截图或复现步骤。

### 许可证

本项目基于 [MIT License](LICENSE) 开源。Copyright (c) 2026 A1straowo。

---

<a id="日本語"></a>

## 日本語

### 概要

Neonote は、Flutter で作られた Android ファースト・ローカルファーストのノートアプリです。リッチテキストノート、手描きキャンバス、MomoTalk 風のキャラクターチャット、任意で利用できる DeepSeek AI を 1 つにまとめています。アカウント登録や必須のクラウド同期はなく、AI 機能を使うときだけネットワークへ接続します。

### 主な機能

- 見出し・太字・斜体・下線・取り消し線・配置・文単位の文字色に対応したリッチテキスト。
- チェックリスト、区切り線、現在時刻の挿入、複数ブロック編集。
- 鉛筆・マーカー・ハイライター・消しゴム・太さ・元に戻す/やり直し・ズーム・グリッド背景を備えた描画キャンバス。
- 画像・音声の埋め込み、画像背景のトリミング、録音と再生。
- タグ、全文検索、アーカイブ、自動保存、未保存ダイアログ、復元ドラフト。
- MomoTalk 風チャット：生徒/先生として送信、立ち絵ギャラリー、プロフィール設定、メッセージ編集・並べ替え・スクリーンショット。
- DeepSeek AI：独自 API Key、Base URL、モデル、システムプロンプト、履歴検索、画像/音声添付、Markdown 返信、返信の編集・再生成・ノート挿入。
- Material 3、ライト/ダーク/システム、カスタム配色、6 言語の UI、ストレージ最適化。

### ダウンロード

最新版は **v1.0.4** です。通常は `arm64-v8a`、互換性重視なら `universal` を選んでください。

- [GitHub Releases（公式）](https://github.com/A1straowo/Neonote/releases/latest)
- **GitHub が利用できない場合の公式ミラー：<https://a1straowo.github.io/Neonote/>**
- [arm64-v8a ミラー](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-arm64-v8a.apk) · [armeabi-v7a ミラー](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-armeabi-v7a.apk) · [x86_64 ミラー](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-x86_64.apk) · [universal ミラー](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-universal.apk)
- [SHA256SUMS.txt](https://a1straowo.github.io/Neonote/SHA256SUMS.txt)

> 現在の APK はテスト用の Android デバッグ証明書で署名されています。本番配布時は私有の release keystore で再署名してください。

### ビルド

Flutter 3.47.x、JDK 21、Android SDK Platform 36 / Build Tools 36.x が必要です。

```bash
git clone https://github.com/A1straowo/Neonote.git
cd Neonote
flutter pub get
flutter test
flutter build apk --release
```

### ライセンス

[MIT License](LICENSE) / Copyright (c) 2026 A1straowo.

---

<a id="한국어"></a>

## 한국어

### 소개

Neonote는 Flutter로 만든 Android 우선·로컬 우선 노트 앱입니다. 리치 텍스트 노트, 드로잉 캔버스, MomoTalk 스타일 캐릭터 채팅, 선택형 DeepSeek AI를 하나의 작업 공간에 담았습니다. 계정이나 필수 클라우드 동기화는 없으며, AI 기능을 사용할 때만 네트워크에 연결됩니다.

### 주요 기능

- 제목, 굵게, 기울임, 밑줄, 취소선, 정렬, 문장별 글자색을 지원하는 리치 텍스트.
- 체크리스트, 구분선, 현재 시간 삽입, 여러 블록 편집.
- 연필, 마커, 형광펜, 지우개, 굵기, 실행 취소/다시 실행, 확대/축소, 격자 배경을 갖춘 드로잉 캔버스.
- 이미지·오디오 삽입, 이미지 배경 자르기, 녹음 및 재생.
- 태그, 전체 텍스트 검색, 보관함, 자동 저장, 미저장 알림, 복구 초안.
- MomoTalk 스타일 채팅: 학생/선생님으로 보내기, 초상화 갤러리, 프로필 설정, 메시지 편집·정렬·스크린샷.
- DeepSeek AI: 자체 API Key, Base URL, 모델, 시스템 프롬프트, 기록 검색, 이미지/음성 첨부, Markdown 답변, 답변 편집·재생성·노트 삽입.
- Material 3, 라이트/다크/시스템, 사용자 지정 팔레트, 6개 UI 언어, 저장 공간 최적화.

### 다운로드

최신 버전은 **v1.0.4**입니다. 대부분의 최신 휴대폰에는 `arm64-v8a`, 최대 호환성이 필요하면 `universal`을 선택하세요.

- [GitHub Releases(공식)](https://github.com/A1straowo/Neonote/releases/latest)
- **GitHub 다운로드가 안 될 때 공식 미러: <https://a1straowo.github.io/Neonote/>**
- [arm64-v8a 미러](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-arm64-v8a.apk) · [armeabi-v7a 미러](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-armeabi-v7a.apk) · [x86_64 미러](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-x86_64.apk) · [universal 미러](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-universal.apk)
- [SHA256SUMS.txt](https://a1straowo.github.io/Neonote/SHA256SUMS.txt)

> 현재 APK는 테스트용 Android 디버그 키로 서명되어 있습니다. 실제 배포 시에는 비공개 release keystore로 다시 서명해야 합니다.

### 빌드

Flutter 3.47.x, JDK 21, Android SDK Platform 36 / Build Tools 36.x가 필요합니다.

```bash
git clone https://github.com/A1straowo/Neonote.git
cd Neonote
flutter pub get
flutter test
flutter build apk --release
```

### 라이선스

[MIT License](LICENSE) / Copyright (c) 2026 A1straowo.

---

<a id="español"></a>

## Español

### Descripción general

Neonote es una aplicación de notas para Android, creada con Flutter y diseñada con un enfoque local-first. Combina un editor de texto enriquecido, un lienzo de dibujo, un espacio de chat con personajes inspirado en MomoTalk y un asistente DeepSeek opcional. No requiere cuenta ni sincronización en la nube: solo se conecta a la red cuando utilizas una función de IA.

### Funciones principales

- Notas con formato enriquecido: títulos, negrita, cursiva, subrayado, tachado, alineación y color por frase.
- Listas de verificación, separadores, inserción de la hora actual y edición por bloques.
- Lienzo con lápiz, rotulador, resaltador, goma, grosor, deshacer/rehacer, zoom y fondos de cuadrícula o puntos.
- Notas con imágenes y audio, recorte de fondos, grabación y reproducción.
- Etiquetas, búsqueda de texto completo, archivo, guardado automático y borradores de recuperación.
- Chat inspirado en MomoTalk: mensajes como estudiante o profesor, galería de retratos, perfiles, edición y reordenación de mensajes.
- IA DeepSeek: API Key propia, Base URL, modelo, prompt del sistema, historial, adjuntos de imagen/voz, respuestas Markdown y acciones sobre mensajes.
- Material 3, modo claro/oscuro/sistema, paletas personalizadas, seis idiomas de interfaz y optimización del almacenamiento.

### Descarga

La versión más reciente es **v1.0.4**. Para la mayoría de teléfonos modernos elige `arm64-v8a`; para máxima compatibilidad usa `universal`.

- [GitHub Releases (oficial)](https://github.com/A1straowo/Neonote/releases/latest)
- **Espejo oficial si GitHub no está disponible: <https://a1straowo.github.io/Neonote/>**
- [Espejo arm64-v8a](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-arm64-v8a.apk) · [Espejo armeabi-v7a](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-armeabi-v7a.apk) · [Espejo x86_64](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-x86_64.apk) · [Espejo universal](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-universal.apk)
- [SHA256SUMS.txt](https://a1straowo.github.io/Neonote/SHA256SUMS.txt)

> Los APK actuales están firmados con la clave de depuración de Android para pruebas. Para una distribución de producción, vuelve a firmarlos con un keystore privado.

### Compilar

Necesitas Flutter 3.47.x, JDK 21 y Android SDK Platform 36 / Build Tools 36.x.

```bash
git clone https://github.com/A1straowo/Neonote.git
cd Neonote
flutter pub get
flutter test
flutter build apk --release
```

### Licencia

[MIT License](LICENSE) / Copyright (c) 2026 A1straowo.

---

<a id="русский"></a>

## Русский

### Обзор

Neonote — приложение для заметок под Android, созданное на Flutter с приоритетом локального хранения. Оно объединяет редактор форматированного текста, холст для рисования, чат с персонажами в стиле MomoTalk и необязательного помощника DeepSeek. Аккаунт и обязательная облачная синхронизация отсутствуют: приложение обращается к сети только при использовании функций ИИ.

### Основные возможности

- Заметки с заголовками, жирным шрифтом, курсивом, подчёркиванием, зачёркиванием, выравниванием и цветом текста по предложениям.
- Чек-листы, разделители, вставка текущего времени и редактирование блоков.
- Холст: карандаш, маркер, выделитель, ластик, толщина, отмена/повтор, масштабирование, сетка и точечный фон.
- Изображения и аудио в заметках, обрезка фона, запись и воспроизведение звука.
- Теги, полнотекстовый поиск, архив, автосохранение и черновики восстановления.
- Чат в стиле MomoTalk: сообщения от ученика или учителя, галерея портретов, настройка профилей, редактирование и сортировка сообщений.
- DeepSeek AI: свой API Key, Base URL, модель, системный промпт, история, вложения изображений/голоса, ответы в Markdown и действия с сообщениями.
- Material 3, светлая/тёмная/системная тема, пользовательские палитры, шесть языков интерфейса и оптимизация хранилища.

### Загрузка

Актуальная версия — **v1.0.4**. Для большинства современных телефонов подойдёт `arm64-v8a`, для максимальной совместимости — `universal`.

- [GitHub Releases (официально)](https://github.com/A1straowo/Neonote/releases/latest)
- **Официальное зеркало, если GitHub недоступен: <https://a1straowo.github.io/Neonote/>**
- [Зеркало arm64-v8a](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-arm64-v8a.apk) · [Зеркало armeabi-v7a](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-armeabi-v7a.apk) · [Зеркало x86_64](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-x86_64.apk) · [Зеркало universal](https://a1straowo.github.io/Neonote/Neonote-v1.0.4-universal.apk)
- [SHA256SUMS.txt](https://a1straowo.github.io/Neonote/SHA256SUMS.txt)

> Текущие APK подписаны отладочным ключом Android и предназначены для тестирования. Для производственной раздачи подпишите сборку собственным закрытым release keystore.

### Сборка

Требуются Flutter 3.47.x, JDK 21 и Android SDK Platform 36 / Build Tools 36.x.

```bash
git clone https://github.com/A1straowo/Neonote.git
cd Neonote
flutter pub get
flutter test
flutter build apk --release
```

### Лицензия

[MIT License](LICENSE) / Copyright (c) 2026 A1straowo.
