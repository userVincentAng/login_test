import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'shop_detail_page.dart';
import 'models/store.dart';
import 'services/store_service.dart';

//April 15
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
  bool _isLoading = true;
  String _errorMessage = '';
  final StoreService _storeService = StoreService();

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

    if (widget.initialPosition != null) {
      _currentPosition = widget.initialPosition;
      _fetchNearbyStores();
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      final status = await Permission.location.request();
      print('📍 Location permission status: $status');

      if (status.isGranted) {
        // Get current position
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        print(
            '📍 Current location: ${position.latitude}, ${position.longitude}');

        setState(() {
          _currentPosition = position;
        });

        // Fetch nearby stores
        await _fetchNearbyStores();
      } else {
        print('❌ Location permission denied');
        setState(() {
          _errorMessage =
              'Location permission is required to find nearby stores';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error getting location: $e');
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNearbyStores() async {
    if (_currentPosition == null) {
      print('❌ Cannot fetch stores: current position is null');
      return;
    }

    print(
        '🔍 Fetching stores for location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');

    try {
      final stores = await _storeService.getNearbyStores(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
      );

      print('📊 Received ${stores.length} stores from API');
      for (var store in stores) {
        print('🏪 Store in list: ${store.name} (${store.storeId})');
      }

      setState(() {
        _nearbyStores = stores;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching stores: $e');
      setState(() {
        _errorMessage = 'Error fetching stores: $e';
        _isLoading = false;
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _currentPosition != null
                    ? '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                    : 'Getting location...',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleDrawer,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _getCurrentLocation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Add cart functionality here
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                          decoration: InputDecoration(
                            hintText: 'Search Restaurant',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: airforceBlue,
                            ),
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
                      const Center(child: CircularProgressIndicator())
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
                    else if (_nearbyStores.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No stores found nearby'),
                        ),
                      )
                    else
                      _buildHorizontalCarousel(
                        context,
                        _nearbyStores
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
                  ],
                ),
              ),
            ),
            // Menu Drawer
            if (_isDrawerOpen)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: screenWidth * (isLargeScreen ? 0.4 : 0.7),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: isSmallScreen ? 80 : 100,
                          color: airforceBlue,
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildDrawerItem(
                                  Icons.home, 'Home', isSmallScreen),
                              _buildDrawerItem(
                                Icons.favorite,
                                'Favorites',
                                isSmallScreen,
                              ),
                              _buildDrawerItem(
                                Icons.history,
                                'Order History',
                                isSmallScreen,
                              ),
                              _buildDrawerItem(
                                Icons.notifications,
                                'Notifications',
                                isSmallScreen,
                              ),
                              _buildDrawerItem(
                                Icons.settings,
                                'Settings',
                                isSmallScreen,
                              ),
                              _buildDrawerItem(
                                Icons.help,
                                'Help & Support',
                                isSmallScreen,
                              ),
                              _buildDrawerItem(
                                Icons.logout,
                                'Logout',
                                isSmallScreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
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
        _toggleDrawer();
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

  Widget _buildHorizontalCarousel(BuildContext context, List<Widget> items) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SizedBox(
      height: isSmallScreen ? 160 : 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8.0 : 16.0,
          vertical: 8.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: items[index],
          );
        },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isSmallScreen ? 90 : 100,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: store?.storeUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        'http://test.shoppazing.com${store!.storeUrl}',
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
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (store != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          store.storeRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
