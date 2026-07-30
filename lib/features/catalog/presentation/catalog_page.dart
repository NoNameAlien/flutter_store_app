import 'package:flutter/material.dart';

import '../../../app/store_scope.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/product_image.dart';
import '../../products/domain/entities/product.dart';
import '../../store/application/store_controller.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = StoreScope.of(context).catalogProducts;
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.storefront_outlined,
        title: 'Каталог пока пуст',
        message: 'Товары, включённые в продажу, появятся здесь автоматически.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisExtent: 362,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) => _CatalogProductCard(product: products[index]),
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock == 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ProductImage(path: product.imagePath, expand: true)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price} ₽',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  outOfStock ? 'Нет в наличии' : 'В наличии: ${product.stock}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: outOfStock ? null : () => _buy(context),
                    child: Text(outOfStock ? 'Нет в наличии' : 'Купить'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _buy(BuildContext context) {
    final result = StoreScope.of(context).buy(product.id);
    final message = switch (result) {
      PurchaseResult.success => 'Покупка оформлена: ${product.name}',
      PurchaseResult.outOfStock => 'К сожалению, товар уже закончился',
      PurchaseResult.unavailable => 'Этот товар больше не продаётся',
      PurchaseResult.productNotFound => 'Товар больше не существует',
      PurchaseResult.invalidProduct => 'Данные товара повреждены',
      PurchaseResult.storageError =>
        'Не удалось сохранить покупку. Попробуйте ещё раз',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: result == PurchaseResult.success
            ? null
            : Theme.of(context).colorScheme.error,
      ),
    );
  }
}
