import 'package:flutter/material.dart';

class ShopDetailPage extends StatefulWidget {
  const ShopDetailPage({super.key});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 2; // BINALOT is selected by default

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: _selectedTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color airforceBlue = Color(0xFF5D8AA8);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with background color
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Gabs Binalot United',
                style: TextStyle(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [airforceBlue, airforceBlue.withOpacity(0.8)],
                  ),
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
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'WINGS'),
                  Tab(text: 'ALACARTE'),
                  Tab(text: 'BINALOT'),
                  Tab(text: 'SILOG'),
                  Tab(text: 'PULUTAN'),
                ],
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
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMenuItem(
                  '(B-BB) Boneless Bangus',
                  '109.00',
                  Colors.orange[100]!,
                  isSmallScreen,
                ),
                _buildMenuItem(
                  '(B-BS) Beef Steak',
                  '119.00',
                  Colors.brown[100]!,
                  isSmallScreen,
                ),
                _buildMenuItem(
                  '(B-CA) Chicken Adobo',
                  '99.00',
                  Colors.amber[100]!,
                  isSmallScreen,
                ),
                _buildMenuItem(
                  '(B-CDT) Caldereta',
                  '119.00',
                  Colors.red[100]!,
                  isSmallScreen,
                ),
                _buildMenuItem(
                  '(B-CPA) Chicken Pork Adobo',
                  '119.00',
                  Colors.deepOrange[100]!,
                  isSmallScreen,
                ),
                _buildMenuItem(
                  '(B-LI) Liempo',
                  '119.00',
                  Colors.pink[100]!,
                  isSmallScreen,
                ),
                _buildMenuItem(
                  '(B-LK) Lechon Kawali',
                  '129.00',
                  Colors.brown[200]!,
                  isSmallScreen,
                ),
              ]),
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
    bool isSmallScreen,
  ) {
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
            // Add item to cart functionality
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
