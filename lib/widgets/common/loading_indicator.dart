import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<TerraThemeExtension>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: TextStyle(color: ext?.textSecondary)),
          ],
        ],
      ),
    );
  }
}