import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop_item.dart';
import '../providers/profile_provider.dart';
import '../providers/shop_provider.dart';
import '../theme/theme_extensions.dart';
import '../widgets/common/gradient_text.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadShop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Consumer<ShopProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: ext?.danger),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load shop',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => provider.loadShop(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadShop,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPointsBalanceCard(context, provider),
                const SizedBox(height: 24),
                Text(
                  'Available Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.items.map(
                  (item) => _buildShopItemCard(context, item, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPointsBalanceCard(BuildContext context, ShopProvider provider) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.monetization_on,
                color: ext?.warning ?? theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Balance',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: ext?.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GradientText(
                    '${provider.userPoints}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    gradient: ext?.pointsGradient,
                  ),
                ],
              ),
            ),
            Text(
              'coins',
              style: theme.textTheme.titleMedium?.copyWith(
                color: ext?.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItemCard(
    BuildContext context,
    ShopItem item,
    ShopProvider provider,
  ) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();
    final canAfford = provider.userPoints >= item.cost;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ext?.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Owned count
                if (item.userQuantity != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ext?.surfaceTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Owned: ${item.userQuantity}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ext?.textSecondary,
                      ),
                    ),
                  ),
                const Spacer(),
                // Cost badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 14,
                        color: ext?.warning ?? theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.cost}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: ext?.warning ?? theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Buy button
                FilledButton(
                  onPressed:
                      (canAfford && !provider.isPurchasing)
                          ? () => _confirmPurchase(context, item, provider)
                          : null,
                  child:
                      provider.isPurchasing
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Buy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPurchase(
    BuildContext context,
    ShopItem item,
    ShopProvider provider,
  ) {
    final theme = Theme.of(context);
    final ext = theme.extension<TerraThemeExtension>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Buy ${item.name}?'),
            content: Text(
              'This will cost ${item.cost} coins. You currently have ${provider.userPoints} coins.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  final success = await provider.purchaseStreakFreeze();
                  if (!context.mounted) return;

                  if (success) {
                    context.read<ProfileProvider>().refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} purchased!'),
                        backgroundColor: ext?.success,
                      ),
                    );
                  } else if (provider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error!),
                        backgroundColor: ext?.danger,
                      ),
                    );
                    provider.clearError();
                  }
                },
                child: const Text('Buy'),
              ),
            ],
          ),
    );
  }
}
