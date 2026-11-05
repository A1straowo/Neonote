import 'package:flutter/material.dart';
import 'package:neonote/l10n/app_localizations.dart';

enum ExitSaveDecision { save, discard }

Future<ExitSaveDecision> showExitSaveDialog(BuildContext context) async {
  final result = await showDialog<ExitSaveDecision>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          scrollable: true,
          title: Text(AppLocalizations.of(context)!.exit_unsaved_title),
          content: Text(AppLocalizations.of(context)!.exit_unsaved_message),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, ExitSaveDecision.discard),
              child: Text(AppLocalizations.of(context)!.discard),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, ExitSaveDecision.save),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      );
    },
  );

  return result ?? ExitSaveDecision.discard;
}
