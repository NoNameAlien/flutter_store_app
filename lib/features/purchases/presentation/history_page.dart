import 'package:flutter/material.dart';

import '../../../app/store_scope.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/entities/purchase.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final purchases = StoreScope.of(context).purchases;
    if (purchases.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Покупок ещё не было',
        message: 'После оформления заказа он сразу появится в этой истории.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: purchases.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _PurchaseCard(purchase: purchases[index]),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        purchase.productName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatDate(purchase.purchasedAt)}\n${purchase.quantity} шт. × ${purchase.unitPrice} ₽',
      ),
      isThreeLine: true,
      trailing: Text(
        'Итого\n${purchase.total} ₽',
        textAlign: TextAlign.right,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    ),
  );

  String _formatDate(DateTime date) {
    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'мая',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)} ${months[date.month - 1]} ${date.year}, ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}
