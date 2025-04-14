import 'package:flutter/material.dart';
import 'shop_detail_page.dart';

//April 15
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDrawerOpen = false;
  int _selectedIndex = 0;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                'Current Location',
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
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Add cart functionality here
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      ),
                    ),
                  ),
                ),

                // Nearby Stores Section
                _buildSectionTitle('Nearby Stores', isSmallScreen),
                _buildHorizontalCarousel(context, [
                  _buildStoreCard(
                    'Gabs Binalot United',
                    Colors.orange[100]!,
                    isSmallScreen,
                  ),
                  _buildStoreCard(
                    'Jollibee - Main Street',
                    Colors.blue[100]!,
                    isSmallScreen,
                  ),
                  _buildStoreCard(
                    'McDonald\'s - City Center',
                    Colors.green[100]!,
                    isSmallScreen,
                  ),
                ]),

                // Recommended For You Section
                _buildSectionTitle('Recommended For You', isSmallScreen),
                _buildHorizontalCarousel(context, [
                  _buildStoreCard(
                    'Mang Inasal - Plaza',
                    Colors.red[100]!,
                    isSmallScreen,
                  ),
                  _buildStoreCard(
                    'KFC - Downtown',
                    Colors.purple[100]!,
                    isSmallScreen,
                  ),
                  _buildStoreCard(
                    'Chowking Express',
                    Colors.teal[100]!,
                    isSmallScreen,
                  ),
                ]),

                // Popular Restaurants Section
                _buildSectionTitle('Popular Restaurants', isSmallScreen),
                _buildHorizontalCarousel(context, [
                  _buildStoreCard(
                    'Max\'s Restaurant',
                    Colors.amber[100]!,
                    isSmallScreen,
                  ),
                  _buildStoreCard(
                    'Shakey\'s Pizza',
                    Colors.indigo[100]!,
                    isSmallScreen,
                  ),
                  _buildStoreCard(
                    'Greenwich Pizza',
                    Colors.pink[100]!,
                    isSmallScreen,
                  ),
                ]),

                // Popular Shops Section
                _buildSectionTitle('Local Food Shops', isSmallScreen),
                _buildHorizontalCarousel(context, [
                  _buildStoreCard(
                    'Aling Nena\'s Carinderia',
                    Colors.cyan[100]!,
                    isSmallScreen,
                  ),
                  _buildStoreCard(
                    'Juan\'s BBQ House',
                    Colors.brown[100]!,
                    isSmallScreen,
                  ),
                  _buildStoreCard(
                    'Manong\'s Sisig Corner',
                    Colors.lime[100]!,
                    isSmallScreen,
                  ),
                ]),

                // Add bottom padding for navigation bar
                SizedBox(height: isSmallScreen ? 60 : 70),
              ],
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
                            _buildDrawerItem(Icons.home, 'Home', isSmallScreen),
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
    return SizedBox(
      height: MediaQuery.of(context).size.width < 360 ? 180 : 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 360 ? 8.0 : 16.0,
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
    bool isSmallScreen,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShopDetailPage()),
        );
      },
      child: Container(
        width: isSmallScreen ? 140 : 160,
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
              height: isSmallScreen ? 100 : 120,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
