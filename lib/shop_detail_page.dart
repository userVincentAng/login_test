import 'package:flutter/material.dart';
import 'models/store.dart';
import 'models/store_item.dart';
import 'services/store_service.dart';
import 'customize_order.dart';
import 'package:shimmer/shimmer.dart';
import 'widgets/shimmer_widget.dart';

class StoreInfoDialog extends StatefulWidget {
  final Store store;

  const StoreInfoDialog({
    super.key,
    required this.store,
  });

  @override
  State<StoreInfoDialog> createState() => _StoreInfoDialogState();
}

class _StoreInfoDialogState extends State<StoreInfoDialog> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }

  Widget _buildShimmerContainer(double height, [double? width]) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Google Maps placeholder with shimmer
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.white,
                          ),
                        )
                      : const Center(
                          child: Image(
                            image: AssetImage('assets/images/google_logo.png'),
                            width: 100,
                          ),
                        ),
                ),
                // Close button
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store name
                  _isLoading
                      ? _buildShimmerContainer(30, 200)
                      : Text(
                          widget.store.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 16),
                  // Location section
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Address
                  _isLoading
                      ? _buildShimmerContainer(20)
                      : Text(
                          widget.store.addressLine1,
                          style: const TextStyle(fontSize: 16),
                        ),
                  if (widget.store.addressLine2 != null) ...[
                    const SizedBox(height: 4),
                    _isLoading
                        ? _buildShimmerContainer(20)
                        : Text(
                            widget.store.addressLine2!,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ],
                  const SizedBox(height: 24),
                  // Store Hours section
                  const Text(
                    'Store Hours',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Store hours
                  ...List.generate(7, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: _isLoading
                                ? _buildShimmerContainer(20)
                                : Text(
                                    _getDayName(index),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          _isLoading
                              ? _buildShimmerContainer(20, 100)
                              : Text(
                                  '${widget.store.storeHours[index].startTime} - ${widget.store.storeHours[index].endTime}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  bool _isSmallScreen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStoreItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isSmallScreen = MediaQuery.of(context).size.width < 360;
      });
    });
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

  Widget _buildLoadingMenuItem(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
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
      padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 14,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
          Container(
            width: isSmallScreen ? 70 : 80,
            height: isSmallScreen ? 70 : 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Container(
            width: 120,
            height: 18,
            color: Colors.grey[200],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) =>
              _buildLoadingMenuItem(_isSmallScreen),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color airforceBlue = Color(0xFF5D8AA8);

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
                child: widget.store.storeUrl.isNotEmpty
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => StoreInfoDialog(store: widget.store),
                  );
                },
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
            padding: EdgeInsets.all(_isSmallScreen ? 12.0 : 16.0),
            sliver: _isLoading
                ? SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildLoadingCategory(),
                        const SizedBox(height: 16),
                        _buildLoadingCategory(),
                      ],
                    ),
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
                                      _isSmallScreen,
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
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
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
