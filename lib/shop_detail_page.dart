import 'package:flutter/material.dart';
import 'models/store.dart';
import 'models/store_item.dart';
import 'services/store_service.dart';
import 'customize_order.dart';
import 'package:shimmer/shimmer.dart';

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
                          child: Container(color: Colors.white),
                        )
                      : const Center(
                          child: Image(
                            image: AssetImage('assets/images/google_logo.png'),
                            width: 100,
                          ),
                        ),
                ),
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
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const Text(
                    'Store Hours',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
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
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final result = await _storeService.getStoreItems(widget.store.storeId);
      if (result == null ||
          result['items'] == null ||
          result['categories'] == null) {
        throw Exception('Invalid response from server');
      }

      setState(() {
        _items = result['items'] ?? [];
        _categories = result['categories'] ?? [];
        _isLoading = false;
      });

      if (_categories.isNotEmpty) {
        _tabController = TabController(length: _categories.length, vsync: this);
        _tabController.addListener(() {
          if (_tabController.indexIsChanging) {
            _scrollToCategory(_tabController.index);
          }
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateCategoryPositions();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading items: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _calculateCategoryPositions() {
    if (_categories.isEmpty) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    double currentPosition = 0;
    for (var category in _categories) {
      if (category.id != null) {
        _categoryPositions[category.id!] = currentPosition;
        currentPosition += 56;
        final categoryItems =
            _items.where((item) => item.categoryId == category.id).length;
        currentPosition += (categoryItems * 100.0);
      }
    }
  }

  void _scrollToCategory(int categoryIndex) {
    if (categoryIndex < 0 || categoryIndex >= _categories.length) return;

    final category = _categories[categoryIndex];
    if (category.id != null) {
      final position = _categoryPositions[category.id!];
      if (position != null) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onScroll() {
    if (_categories.isEmpty) return;

    final currentPosition = _scrollController.position.pixels;
    int newSelectedTab = 0;

    for (var i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      final position = _categoryPositions[category.id];
      if (position != null && currentPosition >= position) {
        newSelectedTab = i;
      }
    }

    if (newSelectedTab != _selectedTab) {
      setState(() {
        _selectedTab = newSelectedTab;
      });
      if (_tabController.index != newSelectedTab) {
        _tabController.animateTo(newSelectedTab);
      }
    }
  }

  Widget _buildLoadingMenuItem() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.white,
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

  Widget _buildLoadingCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              width: 120,
              height: 18,
              color: Colors.white,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => _buildLoadingMenuItem(),
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
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.store.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
          if (!_isLoading && _errorMessage.isEmpty)
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(width: 3, color: airforceBlue),
                    insets: EdgeInsets.symmetric(
                        horizontal: _isSmallScreen ? 8 : 16),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
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
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: _isSmallScreen ? 12.0 : 20.0,
              vertical: 8.0,
            ),
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
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        offset: const Offset(0, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 24, 16, 16),
                                        child: Text(
                                          category.categoryName,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                      if (categoryItems.length == 1)
                                        _buildItemCard(categoryItems[0])
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: categoryItems.length,
                                          separatorBuilder: (context, index) =>
                                              const Divider(
                                            height: 1,
                                            thickness: 0.5,
                                            color: Color(0xFFE0E0E0),
                                          ),
                                          itemBuilder: (context, index) {
                                            return _buildItemCard(
                                                categoryItems[index]);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show order summary
        },
        backgroundColor: airforceBlue,
        elevation: 4,
        icon: const Icon(Icons.shopping_bag),
        label: const Text("View Order"),
        heroTag: 'shop_detail_fab',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildItemCard(StoreItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
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
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₱${(item.price * 1.10).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5D8AA8),
                    ),
                  ),
                  if (item.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: item.imgUrl.isNotEmpty
                        ? Image.network(
                            'http://test.shoppazing.com/api${item.imgUrl}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    size: 40,
                                    color: Colors.black38,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 40,
                                color: Colors.black38,
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF5D8AA8),
                    elevation: 2,
                    heroTag: 'add_item_${item.id}',
                    child: const Icon(Icons.add, size: 20),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.7,
                          minChildSize: 0.5,
                          maxChildSize: 0.9,
                          builder: (context, scrollController) =>
                              CustomizeOrderPanel(
                            item: item,
                            storeId: widget.store.storeId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
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
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
