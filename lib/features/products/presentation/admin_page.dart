import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/store_scope.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/product_image.dart';
import '../../store/application/store_controller.dart';
import '../domain/entities/product.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _imagePicker = ImagePicker();
  String? _imagePath;
  String? _imageError;
  bool _isAvailable = true;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (!mounted || image == null) return;
      setState(() {
        _imagePath = image.path;
        _imageError = null;
      });
    } on PlatformException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть галерею. Проверьте доступ к фото.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось выбрать изображение. Повторите попытку.'),
        ),
      );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      setState(() => _imageError = 'Выберите изображение товара');
      return;
    }
    StoreScope.of(context).addProduct(
      name: _nameController.text,
      price: int.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      imagePath: _imagePath!,
      isAvailable: _isAvailable,
    );
    _formKey.currentState!.reset();
    _nameController.clear();
    _priceController.clear();
    _stockController.text = '1';
    setState(() {
      _imagePath = null;
      _imageError = null;
      _isAvailable = true;
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Товар добавлен в каталог')));
  }

  @override
  Widget build(BuildContext context) {
    final products = StoreScope.of(context).products;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _ProductForm(
          formKey: _formKey,
          nameController: _nameController,
          priceController: _priceController,
          stockController: _stockController,
          imagePath: _imagePath,
          imageError: _imageError,
          isAvailable: _isAvailable,
          onImageTap: _pickImage,
          onAvailabilityChanged: (value) =>
              setState(() => _isAvailable = value),
          onSubmit: _submit,
        ),
        const SizedBox(height: 28),
        Text('Все товары', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (products.isEmpty)
          const SizedBox(
            height: 220,
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Товаров пока нет',
              message:
                  'Заполните форму выше — товар сразу появится в каталоге.',
            ),
          )
        else
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AdminProductCard(product: product),
            ),
          ),
      ],
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({
    required this.formKey,
    required this.nameController,
    required this.priceController,
    required this.stockController,
    required this.imagePath,
    required this.imageError,
    required this.isAvailable,
    required this.onImageTap,
    required this.onAvailabilityChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final String? imagePath;
  final String? imageError;
  final bool isAvailable;
  final VoidCallback onImageTap;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onSubmit;

  String? _positiveNumberValidator(String? value, String label) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number < 0 || (label == 'Цена' && number == 0)) {
      return '$label укажите целым числом${label == 'Цена' ? ' больше нуля' : ' от нуля'}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Новый товар', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Название товара'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Введите название'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Цена, ₽'),
                    validator: (value) =>
                        _positiveNumberValidator(value, 'Цена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Количество'),
                    validator: (value) =>
                        _positiveNumberValidator(value, 'Количество'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onImageTap,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                imagePath == null
                    ? 'Выбрать изображение'
                    : 'Изображение выбрано',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xffd9deeb)),
              ),
            ),
            if (imageError != null) ...[
              const SizedBox(height: 6),
              Text(
                imageError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (imagePath != null) ...[
              const SizedBox(height: 12),
              ProductImage(path: imagePath, size: 100),
            ],
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: isAvailable,
              onChanged: onAvailabilityChanged,
              title: const Text('В продаже'),
              subtitle: Text(
                isAvailable ? 'Будет виден покупателям' : 'Скрыт из каталога',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.add),
              label: const Text('Добавить товар'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AdminProductCard extends StatelessWidget {
  const _AdminProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(path: product.imagePath),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price} ₽',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Уменьшить остаток',
                        onPressed: product.stock == 0
                            ? null
                            : () => controller.changeStock(product.id, -1),
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${product.stock}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Увеличить остаток',
                        onPressed: () => controller.changeStock(product.id, 1),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch.adaptive(
                  value: product.isAvailable,
                  onChanged: (value) =>
                      controller.changeAvailability(product.id, value),
                ),
                IconButton(
                  tooltip: 'Удалить товар',
                  onPressed: () => _confirmDelete(context, controller),
                  color: Theme.of(context).colorScheme.error,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    StoreController controller,
  ) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text(
          '«${product.name}» исчезнет из каталога. История покупок сохранится.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (approved == true) controller.deleteProduct(product.id);
  }
}
