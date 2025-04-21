import 'package:flutter/material.dart';
import 'models/store.dart';
import 'models/store_item.dart';
import 'services/store_service.dart';
import 'customize_order.dart';

class ShopDetailPage extends StatefulWidget {
  final Store store;

  const ShopDetailPage({super.key, required this.store});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StoreService _storeService = StoreService();
  List<StoreItem> _items = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedTab = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<int, double> _categoryPositions = {};

  @override
  void initState() {
    super.initState();
    _loadStoreItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreItems() async {
    try {
      final result = await _storeService.getStoreItems(widget.store.storeId);
      setState(() {
        _items = result['items'];
        _categories = result['categories'];
        _isLoading = false;
      });
      // Initialize tab controller after categories are loaded
      _tabController = TabController(
        length: _categories.length,
        vsync: this,
        initialIndex: _selectedTab,
      );
      _tabController.addListener(() {
        if (_tabController.indexIsChanging) {
          _scrollToCategory(_tabController.index);
        }
      });
      // Calculate category positions after items are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateCategoryPositions();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading items: $e';
        _isLoading = false;
      });
    }
  }

  void _calculateCategoryPositions() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    double currentPosition = 0;
    for (var category in _categories) {
      _categoryPositions[category.id] = currentPosition;
      // Add height of category header
      currentPosition += 56; // Approximate height of category header
      // Add height of items in this category
      final categoryItems =
          _items.where((item) => item.categoryId == category.id).length;
      currentPosition +=
          (categoryItems * 100.0); // Approximate height of each item
    }
  }

  void _scrollToCategory(int categoryIndex) {
    if (categoryIndex < 0 || categoryIndex >= _categories.length) return;

    final category = _categories[categoryIndex];
    final position = _categoryPositions[category.id];
    if (position != null) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onScroll() {
    if (_categories.isEmpty) return;

    final currentPosition = _scrollController.position.pixels;
    int newSelectedTab = 0;

    // Find the category that's currently most visible
    for (var i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      final position = _categoryPositions[category.id];
      if (position != null && currentPosition >= position) {
        newSelectedTab = i;
      }
    }

    // Update selected tab if it changed
    if (newSelectedTab != _selectedTab) {
      setState(() {
        _selectedTab = newSelectedTab;
      });
      // Update tab controller without triggering scroll
      if (_tabController.index != newSelectedTab) {
        _tabController.animateTo(newSelectedTab);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color airforceBlue = Color(0xFF5D8AA8);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar with background color
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.store.name,
                style: const TextStyle(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [airforceBlue, airforceBlue.withOpacity(0.8)],
                  ),
                ),
                child: widget.store.storeUrl != null
                    ? Image.network(
                        'http://test.shoppazing.com/api${widget.store.storeUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.store,
                                size: 40, color: Colors.white),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.store, size: 40, color: Colors.white),
                      ),
              ),
            ),
            backgroundColor: airforceBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {},
              ),
            ],
          ),
          // Tab Bar
          if (!_isLoading && _errorMessage.isEmpty)
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _categories
                      .map((category) => Tab(text: category.categoryName))
                      .toList(),
                  labelColor: airforceBlue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: airforceBlue,
                ),
              ),
              pinned: true,
            ),
          // Menu Items
          SliverPadding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            sliver: _isLoading
                ? SliverToBoxAdapter(
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : _errorMessage.isNotEmpty
                    ? SliverToBoxAdapter(
                        child: Center(child: Text(_errorMessage)),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate(
                          _categories.map((category) {
                            final categoryItems = _items
                                .where((item) => item.categoryId == category.id)
                                .toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  color: Colors.grey[200],
                                  child: Text(
                                    category.categoryName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...categoryItems.map((item) => _buildMenuItem(
                                      item.productName,
                                      item.price.toStringAsFixed(2),
                                      Colors.orange[100]!,
                                      isSmallScreen,
                                      item: item,
                                    )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String name,
    String price,
    Color backgroundColor,
    bool isSmallScreen, {
    StoreItem? item,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            if (item != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) => CustomizeOrderPanel(
                    item: item,
                    storeId: widget.store.storeId,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        '₱$price',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: const Color(0xFF5D8AA8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: isSmallScreen ? 70 : 80,
                  height: isSmallScreen ? 70 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: backgroundColor,
                  ),
                  child: item?.imgUrl.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'http://test.shoppazing.com/api${item!.imgUrl}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.fastfood, size: 40),
                              );
                            },
                          ),
                        )
                      : const Center(child: Icon(Icons.fastfood, size: 40)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
