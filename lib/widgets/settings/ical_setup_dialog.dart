import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timetable_provider.dart';
import '../../services/ical_service.dart';

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
                suffixIcon: _isValidating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            if (_success != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_success!, style: TextStyle(color: Colors.green.shade700))),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('How to get your iCal URL', style: TextStyle(fontSize: 14)),
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
          child: _isSyncing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Import'),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 10, child: Text(number, style: const TextStyle(fontSize: 10))),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _handleSync() async {
    String url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a URL');
      return;
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

    // Validate URL
    final isValid = await _icalService.validateUrl(url);
    if (!isValid) {
      setState(() {
        _isValidating = false;
        _error = 'Invalid iCal URL. Please check and try again.';
      });
      return;
    }

    setState(() {
      _isValidating = false;
      _isSyncing = true;
    });

    // Sync
    final provider = context.read<TimetableProvider>();
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