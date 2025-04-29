import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'shop_detail_page.dart';
import 'models/store.dart';
import 'models/food_item.dart';
import 'models/address.dart';
import 'services/store_service.dart';
import 'services/auth_service.dart';
import 'saved_addresses_page.dart';
import 'services/address_service.dart';
import 'services/cart_service.dart';
import 'cart_page.dart';
import 'widgets/shimmer_widget.dart';

//April 30
class HomePage extends StatefulWidget {
  final Position? initialPosition;
  const HomePage({super.key, this.initialPosition});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDrawerOpen = false;
  int _selectedIndex = 0;
  Position? _currentPosition;
  List<Store> _nearbyStores = [];
  List<Store> _filteredStores = [];
  List<FoodItem> _nearbyFood = [];
  List<FoodItem> _filteredFood = [];
  bool _isLoading = true;
  bool _isFoodLoading = true;
  String _errorMessage = '';
  String _selectedAddress = '';
  final StoreService _storeService = StoreService();
  final AddressService _addressService = AddressService();
  final TextEditingController _searchController = TextEditingController();
  final CartService _cartService = CartService();
  int _cartItemCount = 0;
  Address? _selectedAddressObject;
  final ScrollController _drawerScrollController = ScrollController();
  String _currentAddress = '';
  String _currentLabel = '';
  String _floorUnit = '';
  String _deliveryInstructions = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeLocation();

    _searchController.addListener(_onSearchChanged);
    _loadCartCount();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _drawerScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredStores = _nearbyStores;
        _filteredFood = _nearbyFood;
      } else {
        _filteredStores = _nearbyStores.where((store) {
          final matches = store.name.toLowerCase().contains(query);
          return matches;
        }).toList();

        _filteredFood = _nearbyFood.where((food) {
          final matches = food.name.toLowerCase().contains(query) ||
              food.storeName.toLowerCase().contains(query);
          return matches;
        }).toList();
      }
    });
  }

  Future<void> _initializeLocation() async {
    if (widget.initialPosition != null) {
      _currentPosition = widget.initialPosition;
      _fetchNearbyStores();
    } else {
      final defaultAddress = await _addressService.getDefaultAddress();
      if (defaultAddress != null) {
        setState(() {
          _currentPosition = Position(
            latitude: defaultAddress.coordinates.latitude,
            longitude: defaultAddress.coordinates.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
          _selectedAddress = defaultAddress.fullAddress;
          _selectedAddressObject = defaultAddress;
        });
        _fetchNearbyStores();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _errorMessage = '';
      });
      _fetchNearbyStores();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
      });
    }
  }

  Future<void> _fetchNearbyStores() async {
    if (_currentPosition == null) {
      setState(() {
        _errorMessage = 'Location not available';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final stores = await _storeService.getNearbyStores(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
      );

      setState(() {
        _nearbyStores = stores;
        _filteredStores = stores;
        _isLoading = false;
      });

      // Fetch nearby food for the first store
      if (stores.isNotEmpty) {
        await _fetchNearbyFood(stores.first.storeId);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching stores: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNearbyFood(int storeId) async {
    try {
      setState(() {
        _isFoodLoading = true;
        _errorMessage = '';
      });

      final foods = await _storeService.getNearbyFood(storeId);

      setState(() {
        _nearbyFood = foods;
        _filteredFood = foods;
        _isFoodLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching nearby food: $e';
        _isFoodLoading = false;
      });
    }
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    try {
      // Show confirmation dialog
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Logout'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        // Close the drawer first
        _toggleDrawer();

        // Attempt to logout
        final bool success = await AuthService.logout();

        if (success) {
          // Show loading indicator
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logging out...'),
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to login page
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (Route<dynamic> route) => false,
          );

          // Show success message
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Logout failed');
        }
      }
    } catch (e) {
      //print('Error during logout: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SavedAddressesPage(
          onAddressSelected:
              (latLng, address, floorUnit, instructions, label) async {
            setState(() {
              _currentPosition = Position(
                latitude: latLng.latitude,
                longitude: latLng.longitude,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0,
                altitudeAccuracy: 0,
                headingAccuracy: 0,
              );
              _currentAddress = address;
              _currentLabel = label;
              _floorUnit = floorUnit;
              _deliveryInstructions = instructions;
            });
            await _fetchNearbyStores();
          },
        ),
      ),
    );
  }

  Future<void> _loadCartCount() async {
    await _cartService.loadCart();
    setState(() {
      _cartItemCount = _cartService.itemCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color airforceBlue = Color(0xFF5D8AA8);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: airforceBlue,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentLabel.isNotEmpty ? _currentLabel : 'Select Address',
              style: const TextStyle(fontSize: 16),
            ),
            if (_currentAddress.isNotEmpty)
              Text(
                _currentAddress,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleDrawer,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _selectAddress,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  ).then((_) => _loadCartCount());
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                await _getCurrentLocation();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: bottomPadding + (isSmallScreen ? 60 : 70)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12.0 : 16.0,
                          vertical: isSmallScreen ? 8.0 : 16.0,
                        ),
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
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Restaurant or Food',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: airforceBlue,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.all(isSmallScreen ? 12 : 16),
                            ),
                          ),
                        ),
                      ),

                      // Nearby Stores Section
                      _buildSectionTitle('Nearby Stores', isSmallScreen),
                      if (_isLoading)
                        _buildHorizontalCarousel(
                          context,
                          [],
                          isLoading: true,
                          isStore: true,
                        )
                      else if (_errorMessage.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else if (_filteredStores.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No stores found'),
                          ),
                        )
                      else
                        _buildHorizontalCarousel(
                          context,
                          _filteredStores
                              .map(
                                (store) => _buildStoreCard(
                                  store.name,
                                  Colors.orange[100]!,
                                  isSmallScreen,
                                  store: store,
                                ),
                              )
                              .toList(),
                        ),

                      // Nearby Food Section
                      const SizedBox(height: 24),
                      _buildSectionTitle('Nearby Food', isSmallScreen),
                      if (_isFoodLoading)
                        _buildHorizontalCarousel(
                          context,
                          [],
                          isLoading: true,
                        )
                      else if (_filteredFood.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No food items found'),
                          ),
                        )
                      else
                        _buildHorizontalCarousel(
                          context,
                          _filteredFood
                              .map(
                                (food) => _buildFoodCard(
                                  food.name,
                                  food.price.toStringAsFixed(2),
                                  Colors.green[100]!,
                                  isSmallScreen,
                                  food: food,
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Menu Drawer
          if (_isDrawerOpen)
            Container(
              color: Colors.black.withOpacity(0.5),
              width: screenWidth,
              height: screenHeight,
            ),
          if (_isDrawerOpen)
            Positioned(
              left: 0,
              top: 0,
              height: screenHeight,
              width: screenWidth * (isLargeScreen ? 0.4 : 0.7),
              child: Material(
                elevation: 16,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    color: Colors.white,
                    height: screenHeight,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          Container(
                            height: isSmallScreen ? 80 : 100,
                            color: airforceBlue,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: isSmallScreen ? 20 : 25,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    color: airforceBlue,
                                    size: isSmallScreen ? 24 : 30,
                                  ),
                                ),
                                SizedBox(width: isSmallScreen ? 12 : 16),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                    Text(
                                      'Sign in to your account',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Scrollbar(
                              controller: _drawerScrollController,
                              thumbVisibility: true,
                              thickness: 6,
                              radius: const Radius.circular(3),
                              child: ListView(
                                controller: _drawerScrollController,
                                padding: EdgeInsets.zero,
                                children: [
                                  _buildDrawerItem(
                                      Icons.home, 'Home', isSmallScreen),
                                  _buildDrawerItem(Icons.favorite, 'Favorites',
                                      isSmallScreen),
                                  _buildDrawerItem(Icons.history,
                                      'Order History', isSmallScreen),
                                  _buildDrawerItem(Icons.notifications,
                                      'Notifications', isSmallScreen),
                                  _buildDrawerItem(Icons.settings, 'Settings',
                                      isSmallScreen),
                                  _buildDrawerItem(Icons.help, 'Help & Support',
                                      isSmallScreen),
                                  _buildDrawerItem(
                                      Icons.logout, 'Logout', isSmallScreen),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: airforceBlue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: isSmallScreen ? 10 : 12,
          unselectedFontSize: isSmallScreen ? 10 : 12,
          iconSize: isSmallScreen ? 20 : 24,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: 'Rewards',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isSmallScreen) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF5D8AA8),
        size: isSmallScreen ? 20 : 24,
      ),
      title: Text(title, style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
      onTap: () {
        if (title == 'Logout') {
          _handleLogout();
        } else {
          _toggleDrawer();
        }
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12.0 : 16.0,
        vertical: isSmallScreen ? 6.0 : 8.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 18 : 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5D8AA8),
        ),
      ),
    );
  }

  Widget _buildHorizontalCarousel(
    BuildContext context,
    List<Widget> items, {
    bool isLoading = false,
    bool isStore = false,
  }) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;

    if (isLoading) {
      items = List.generate(
        4,
        (index) => isStore
            ? _buildShimmerStoreCard(isSmallScreen)
            : _buildShimmerFoodCard(isSmallScreen),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: item,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShimmerFoodCard(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 130 : 150,
      height: isSmallScreen ? 140 : 160,
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
      child: Column(
        children: [
          ShimmerWidget.rectangular(
            height: isSmallScreen ? 85 : 95,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.rectangular(height: 12),
                  const SizedBox(height: 4),
                  ShimmerWidget.rectangular(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStoreCard(bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 130 : 150,
      height: isSmallScreen ? 140 : 160,
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
      child: Column(
        children: [
          ShimmerWidget.rectangular(
            height: isSmallScreen ? 85 : 95,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.rectangular(height: 12),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ShimmerWidget.rectangular(width: 40, height: 10),
                      const SizedBox(width: 4),
                      ShimmerWidget.rectangular(width: 20, height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(
    String name,
    Color backgroundColor,
    bool isSmallScreen, {
    Store? store,
  }) {
    return InkWell(
      onTap: () {
        if (store != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDetailPage(store: store),
            ),
          );
        }
      },
      child: Container(
        width: isSmallScreen ? 130 : 150,
        height: isSmallScreen ? 140 : 160,
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
        child: Column(
          children: [
            Container(
              height: isSmallScreen ? 85 : 95,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: store?.storeUrl.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        'http://test.shoppazing.com/api${store!.storeUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.store, size: 40),
                          );
                        },
                      ),
                    )
                  : const Center(child: Icon(Icons.store, size: 40)),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (store != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              store.storeRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(
    String name,
    String price,
    Color backgroundColor,
    bool isSmallScreen, {
    FoodItem? food,
  }) {
    return InkWell(
      onTap: () {
        if (food != null) {
          // Navigate to food detail page or show bottom sheet
        }
      },
      child: Container(
        width: isSmallScreen ? 130 : 150,
        height: isSmallScreen ? 140 : 160,
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
        child: Column(
          children: [
            Container(
              height: isSmallScreen ? 85 : 95,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: food?.imgUrl.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        'http://test.shoppazing.com/api${food!.imgUrl}',
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
            Expanded(
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (food != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '₱$price',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
