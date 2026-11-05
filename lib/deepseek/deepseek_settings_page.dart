import 'package:flutter/material.dart';
import 'package:neonote/l10n/app_localizations.dart';
import 'package:neonote/main.dart' show DeviceInfo;
import 'package:neonote/services/deepseek_service.dart';
import 'package:neonote/ui/app_layout.dart';

/// 设置 - 通用 - Deepseek Harness 配置页。
class DeepseekSettingsPage extends StatefulWidget {
  const DeepseekSettingsPage({super.key});

  @override
  State<DeepseekSettingsPage> createState() => _DeepseekSettingsPageState();
}

class _DeepseekSettingsPageState extends State<DeepseekSettingsPage> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  late final TextEditingController _promptController;

  bool _enabled = true;
  bool _obscureKey = true;
  bool _testing = false;
  String? _status;
  bool _statusOk = false;

  @override
  void initState() {
    super.initState();
    final config = DeepseekConfig.load();
    _apiKeyController = TextEditingController(text: config.apiKey);
    _baseUrlController = TextEditingController(text: config.baseUrl);
    _modelController = TextEditingController(text: config.model);
    _promptController = TextEditingController(text: config.systemPrompt);
    _enabled = config.enabled;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  DeepseekConfig _currentConfig() {
    final current = DeepseekConfig.load();
    return DeepseekConfig(
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      model: _modelController.text,
      systemPrompt: _promptController.text,
      enabled: _enabled,
      reasoningLevel: current.reasoningLevel,
      mode: current.mode,
    );
  }

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> _save() async {
    await _currentConfig().save();
    if (!mounted) return;
    _toast(AppLocalizations.of(context)!.deepseek_saved);
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context)!;
    final config = _currentConfig();
    if (!config.isConfigured) {
      _toast(l10n.deepseek_not_configured);
      return;
    }
    setState(() {
      _testing = true;
      _status = null;
    });
    try {
      await DeepseekService.testConnection(config);
      if (!mounted) return;
      setState(() {
        _statusOk = true;
        _status = l10n.deepseek_connected;
      });
      _toast(l10n.deepseek_connected);
    } catch (error) {
      if (!mounted) return;
      final message = '${l10n.deepseek_connection_failed}: $error';
      setState(() {
        _statusOk = false;
        _status = message;
      });
      _toast(message);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.deepseek_harness,
          style: TextStyle(
            fontFamily: 'ResourceHanCN',
            color: scheme.onSurface,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: scheme.surface,
        leading: IconButton(
          tooltip: l10n.close,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ContentPane(
        maxWidth: AppBreakpoints.wideContentMax,
        padding: EdgeInsets.zero,
        child: ListView(
          padding: EdgeInsets.all(DeviceInfo.pt(20)),
          children: [
            _buildCard(
              context,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.deepseek_enable,
                    style: const TextStyle(fontFamily: 'ResourceHanCN'),
                  ),
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
              ],
            ),
            SizedBox(height: DeviceInfo.pt(14)),
            _buildTextField(
              label: l10n.deepseek_api_key,
              controller: _apiKeyController,
              obscureText: _obscureKey,
              suffixIcon: IconButton(
                tooltip: l10n.deepseek_api_key,
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
                icon: Icon(
                  _obscureKey ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            SizedBox(height: DeviceInfo.pt(14)),
            _buildTextField(
              label: l10n.deepseek_base_url,
              controller: _baseUrlController,
              hint: DeepseekConfig.defaultBaseUrl,
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: DeviceInfo.pt(14)),
            _buildTextField(
              label: l10n.deepseek_model,
              controller: _modelController,
              hint: DeepseekConfig.defaultModel,
            ),
            SizedBox(height: DeviceInfo.pt(14)),
            _buildTextField(
              label: l10n.deepseek_system_prompt,
              controller: _promptController,
              maxLines: 4,
            ),
            SizedBox(height: DeviceInfo.pt(24)),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: DeviceInfo.pt(14),
                      ),
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(fontFamily: 'ResourceHanCN'),
                    ),
                  ),
                ),
                SizedBox(width: DeviceInfo.pt(12)),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testing ? null : _testConnection,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: DeviceInfo.pt(14),
                      ),
                    ),
                    child: _testing
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.deepseek_testing,
                                style: const TextStyle(
                                  fontFamily: 'ResourceHanCN',
                                ),
                              ),
                            ],
                          )
                        : Text(
                            l10n.deepseek_test_connection,
                            style: const TextStyle(fontFamily: 'ResourceHanCN'),
                          ),
                  ),
                ),
              ],
            ),
            if (_status != null) ...[
              SizedBox(height: DeviceInfo.pt(16)),
              Row(
                children: [
                  Icon(
                    _statusOk ? Icons.check_circle : Icons.error_outline,
                    size: 18,
                    color: _statusOk ? Colors.green : scheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status!,
                      style: TextStyle(
                        fontFamily: 'ResourceHanCN',
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: scheme.onSurface.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: DeviceInfo.pt(16)),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontFamily: 'ResourceHanCN', color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
