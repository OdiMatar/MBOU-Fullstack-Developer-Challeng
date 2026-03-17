import 'item.dart';

class CartItem {
  final int id;
  final int userId;
  final int itemId;
  final int quantity;
  final Item item;

  CartItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.quantity,
    required this.item,
  });

  double get subtotal => (item.price ?? 0) * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['user_id'],
      itemId: json['item_id'],
      quantity: json['quantity'] ?? 1,
      item: Item.fromJson(json['item'] ?? {}),
    );
  }
}
