import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();

  int? _userId;
  bool _isLoading = true;
  bool _isCheckingOut = false;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  double get _cartTotal =>
      _cartItems.fold(0, (sum, cartItem) => sum + cartItem.subtotal);

  Future<void> _initialize() async {
    final user = await _authService.getUser();

    if (!mounted) {
      return;
    }

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _userId = user['id'];
    await _loadCart();
  }

  Future<void> _loadCart() async {
    if (_userId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _cartService.getUserCart(_userId!);

      if (!mounted) {
        return;
      }

      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij laden winkelwagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeQuantity(CartItem cartItem, int newQuantity) async {
    if (newQuantity < 1) {
      return;
    }

    try {
      await _cartService.updateQuantity(
        cartItemId: cartItem.id,
        quantity: newQuantity,
      );
      await _loadCart();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aantal kon niet worden aangepast: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeItem(CartItem cartItem) async {
    try {
      await _cartService.removeFromCart(cartItem.id);
      await _loadCart();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item kon niet verwijderd worden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkout() async {
    if (_userId == null || _cartItems.isEmpty) {
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      final total = await _cartService.checkout(_userId!);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aankoop geslaagd. Totaal betaald: EUR ${total.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Afrekenen mislukt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  Widget _buildCartItem(CartItem cartItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: SizedBox(
          width: 52,
          height: 52,
          child:
              cartItem.item.imageUrl != null &&
                  cartItem.item.imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cartItem.item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  ),
                )
              : const Icon(Icons.shopping_bag),
        ),
        title: Text(
          cartItem.item.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Per stuk: EUR ${(cartItem.item.price ?? 0).toStringAsFixed(2)}',
            ),
            Text('Subtotaal: EUR ${cartItem.subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      _changeQuantity(cartItem, cartItem.quantity - 1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('${cartItem.quantity}'),
                IconButton(
                  onPressed: () =>
                      _changeQuantity(cartItem, cartItem.quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _removeItem(cartItem),
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Winkelwagen'),
      ),
      body: _cartItems.isEmpty
          ? const Center(child: Text('Je winkelwagen is leeg.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) =>
                  _buildCartItem(_cartItems[index]),
            ),
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Totaal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'EUR ${_cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isCheckingOut ? null : _checkout,
                        child: _isCheckingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Afrekenen'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
