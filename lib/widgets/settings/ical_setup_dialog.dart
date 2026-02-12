import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../providers/timetable_provider.dart';
import '../../services/ical_service.dart';
import '../../theme/theme_extensions.dart';

class ICalSetupDialog extends StatefulWidget {
  final String? currentUrl;

  const ICalSetupDialog({super.key, this.currentUrl});

  @override
  State<ICalSetupDialog> createState() => _ICalSetupDialogState();
}

class _ICalSetupDialogState extends State<ICalSetupDialog> {
  final _controller = TextEditingController();
  final _icalService = ICalService.instance;
  bool _isValidating = false;
  bool _isSyncing = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    if (widget.currentUrl != null) {
      _controller.text = widget.currentUrl!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Timetable'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your university calendar iCal URL:'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'iCal URL',
                hintText: 'https://...',
                border: const OutlineInputBorder(),
                errorText: _error,
                suffixIcon:
                    _isValidating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            if (_success != null)
              Builder(
                builder: (context) {
                  final ext =
                      Theme.of(context).extension<TerraThemeExtension>();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          ext?.successContainer ??
                          Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: ext?.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _success!,
                            style: TextStyle(color: ext?.success),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'How to get your iCal URL',
                style: TextStyle(fontSize: 14),
              ),
              tilePadding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStep('1', 'Go to mytimetable.bath.ac.uk'),
                      _buildStep('2', 'Sign in with your university account'),
                      _buildStep('3', 'Click "Subscribe" or "Export"'),
                      _buildStep('4', 'Copy the iCal/webcal URL'),
                      _buildStep('5', 'Paste the URL above'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isValidating || _isSyncing) ? null : _handleSync,
          child:
              _isSyncing
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Import'),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final ext = theme.extension<TerraThemeExtension>();
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                child: Text(number, style: const TextStyle(fontSize: 10)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ext?.textSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleSync() async {
    String url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a URL');
      return;
    }
    if (!url.contains('://')) {
      url = 'https://$url';
    }

    // Convert webcal to https
    if (url.startsWith('webcal://')) {
      url = url.replaceFirst('webcal://', 'https://');
    }

    setState(() {
      _isValidating = true;
      _error = null;
      _success = null;
    });

    final provider = context.read<TimetableProvider>();

    // Validate URL
    final isValid = await _icalService.validateUrl(url);
    if (!isValid) {
      setState(() {
        _isValidating = false;
        _error =
            kIsWeb
                ? 'Could not access this iCal feed from browser (URL/CORS issue). Try a direct HTTPS feed URL or configure ICAL_CORS_PROXY.'
                : 'Invalid iCal URL. Please check and try again.';
      });
      return;
    }

    setState(() {
      _isValidating = false;
      _isSyncing = true;
    });

    // Sync
    final success = await provider.syncFromIcal(url);

    if (mounted) {
      if (success) {
        final result = provider.lastSyncResult;
        setState(() {
          _isSyncing = false;
          _success = result?.toString() ?? 'Sync complete!';
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _isSyncing = false;
          _error = provider.error ?? 'Sync failed';
        });
      }
    }
  }
}
