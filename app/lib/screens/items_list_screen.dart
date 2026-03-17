import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({super.key});

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _fabAnimationController;
  String _userName = '';
  bool _isAdmin = false;

  String _selectedBrand = 'Alle';
  String _sortBy = 'Nieuwste';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadUserName();
    _loadItems();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final user = await _authService.getUser();
    final isAdmin = await _authService.isAdmin();
    if (user != null) {
      setState(() {
        _userName = user['name'] ?? '';
        _isAdmin = isAdmin;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _apiService.getItems();
      setState(() {
        _allItems = items;
        _applyFilters();
        _isLoading = false;
      });
      _fabAnimationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Item> filtered = List.from(_allItems);

    // Filter op merk
    if (_selectedBrand != 'Alle') {
      filtered = filtered
          .where((item) => item.brand == _selectedBrand)
          .toList();
    }

    // Filter op zoekterm
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (item.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            )) ||
            (item.color?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Sorteren
    switch (_sortBy) {
      case 'Prijs: Laag-Hoog':
        filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'Prijs: Hoog-Laag':
        filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'Naam A-Z':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Voorraad':
        filtered.sort((a, b) => (b.stock ?? 0).compareTo(a.stock ?? 0));
        break;
      case 'Kleur':
        filtered.sort((a, b) => (a.color ?? '').compareTo(b.color ?? ''));
        break;
      default: // Nieuwste
        filtered.sort((a, b) => b.id.compareTo(a.id));
    }

    setState(() {
      _filteredItems = filtered;
    });
  }

  List<String> _getAvailableBrands() {
    final brands = _allItems
        .map((item) => item.brand ?? '')
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
    brands.sort();
    return ['Alle', ...brands];
  }

  void _navigateToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemScreen()),
    );

    if (result == true) {
      _loadItems();
    }
  }

  void _navigateToEditItem(Item item) async {
    if (_isAdmin) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditItemScreen(item: item)),
      );

      if (result == true) {
        _loadItems();
      }
    } else {
      // Voor normale users, ga naar detail scherm
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(item: item),
        ),
      );

      if (result == true) {
        _loadItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAdmin ? 'Odai App (Admin)' : 'Odai App',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_userName.isNotEmpty)
                  Text(
                    'Welkom, $_userName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadUserName();
                  }
                },
                tooltip: 'Profiel',
              ),
              if (_isAdmin)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                  tooltip: 'Gebruikersbeheer',
                ),
              if (!_isAdmin)
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadItems();
                    }
                  },
                  tooltip: 'Winkelwagen',
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadItems,
                tooltip: 'Vernieuwen',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Uitloggen',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Zoek op naam, kleur...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildFilters()),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
      floatingActionButton: _isAdmin
          ? ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabAnimationController,
                curve: Curves.elasticOut,
              ),
              child: FloatingActionButton.extended(
                onPressed: _navigateToAddItem,
                icon: const Icon(Icons.add),
                label: const Text('Nieuw Product'),
                elevation: 4,
              ),
            )
          : null,
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filters & Sorteren',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Merk filter
                _buildFilterChip(
                  label: _selectedBrand,
                  icon: Icons.business,
                  onTap: () => _showBrandFilter(),
                ),
                const SizedBox(width: 8),
                // Sorteer filter
                _buildFilterChip(
                  label: _sortBy,
                  icon: Icons.sort,
                  onTap: () => _showSortOptions(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showBrandFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter op Merk',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._getAvailableBrands().map((brand) {
                return ListTile(
                  leading: Icon(
                    _selectedBrand == brand
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(brand),
                  onTap: () {
                    setState(() {
                      _selectedBrand = brand;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSortOptions() {
    final options = [
      'Nieuwste',
      'Prijs: Laag-Hoog',
      'Prijs: Hoog-Laag',
      'Naam A-Z',
      'Voorraad',
      'Kleur',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sorteren op',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...options.map((option) {
                return ListTile(
                  leading: Icon(
                    _sortBy == option
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(option),
                  onTap: () {
                    setState(() {
                      _sortBy = option;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(64.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Oeps! Er ging iets mis',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadItems,
                icon: const Icon(Icons.refresh),
                label: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Geen producten gevonden',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Probeer een andere filter of zoekterm',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildItemCard(item, index);
      },
    );
  }

  Widget _buildItemCard(Item item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToEditItem(item),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product afbeelding met kleur overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.smartphone,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.smartphone,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  // Kleur badge
                  if (item.color != null && item.color!.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.palette,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.color!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Merk badge
                    if (item.brand != null && item.brand!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.brand!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Product naam
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Prijs en voorraad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.price != null)
                          Text(
                            '€${item.price!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        if (item.stock != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item.stock! > 10
                                  ? Colors.green.shade50
                                  : item.stock! > 0
                                  ? Colors.orange.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.stock! > 10
                                      ? Icons.check_circle
                                      : item.stock! > 0
                                      ? Icons.warning
                                      : Icons.cancel,
                                  size: 16,
                                  color: item.stock! > 10
                                      ? Colors.green
                                      : item.stock! > 0
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.stock} op voorraad',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item.stock! > 10
                                        ? Colors.green.shade700
                                        : item.stock! > 0
                                        ? Colors.orange.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
