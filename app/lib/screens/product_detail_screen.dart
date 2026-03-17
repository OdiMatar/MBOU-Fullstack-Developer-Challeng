import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'edit_item_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Item item;

  const ProductDetailScreen({super.key, required this.item});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();

  bool _isAdmin = false;
  bool _isLoading = true;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final isAdmin = await _authService.isAdmin();
    if (!mounted) {
      return;
    }

    setState(() {
      _isAdmin = isAdmin;
      _isLoading = false;
    });
  }

  Future<void> _showAddToCartDialog() async {
    final user = await _authService.getUser();
    if (user == null || !mounted) {
      return;
    }

    int selectedQuantity = 1;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Toevoegen aan winkelwagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hoeveel wil je toevoegen van ${widget.item.name}?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Aantal:'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (selectedQuantity > 1) {
                            setDialogState(() {
                              selectedQuantity--;
                            });
                          }
                        },
                      ),
                      Text(
                        '$selectedQuantity',
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (selectedQuantity < (widget.item.stock ?? 0)) {
                            setDialogState(() {
                              selectedQuantity++;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Subtotaal: EUR ${((widget.item.price ?? 0) * selectedQuantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _processAddToCart(user['id'], selectedQuantity);
              },
              child: const Text('Toevoegen'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processAddToCart(int userId, int quantity) async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      await _cartService.addToCart(
        userId: userId,
        itemId: widget.item.id,
        quantity: quantity,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$quantity x ${widget.item.name} toegevoegd aan winkelwagen',
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Winkelwagen',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background:
                  widget.item.imageUrl != null &&
                      widget.item.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.smartphone, size: 100),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.smartphone, size: 100),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.item.brand != null &&
                      widget.item.brand!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.item.brand!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.item.color != null &&
                      widget.item.color!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.palette, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          widget.item.color!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (widget.item.price != null)
                    Text(
                      'EUR ${widget.item.price!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (widget.item.stock != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.item.stock! > 10
                            ? Colors.green.shade50
                            : widget.item.stock! > 0
                            ? Colors.orange.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.item.stock! > 10
                                ? Icons.check_circle
                                : widget.item.stock! > 0
                                ? Icons.warning
                                : Icons.cancel,
                            size: 18,
                            color: widget.item.stock! > 10
                                ? Colors.green
                                : widget.item.stock! > 0
                                ? Colors.orange
                                : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.item.stock} op voorraad',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.item.stock! > 10
                                  ? Colors.green.shade700
                                  : widget.item.stock! > 0
                                  ? Colors.orange.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Beschrijving',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: _isAdmin
              ? FilledButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final result = await navigator.push(
                      MaterialPageRoute(
                        builder: (context) => EditItemScreen(item: widget.item),
                      ),
                    );
                    if (result == true) {
                      navigator.pop(true);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Product Bewerken'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                )
              : FilledButton.icon(
                  onPressed: (widget.item.stock ?? 0) > 0 && !_isAddingToCart
                      ? _showAddToCartDialog
                      : null,
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(
                    (widget.item.stock ?? 0) > 0
                        ? (_isAddingToCart
                              ? 'Toevoegen...'
                              : 'Toevoegen aan winkelwagen')
                        : 'Uitverkocht',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
        ),
      ),
    );
  }
}
