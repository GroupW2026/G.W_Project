import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../viewmodels/home_viewmodel.dart';
import 'services_view.dart';
import 'booking_view.dart';
import 'account_view.dart';
import 'cart_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const BookingView(isFromNavBar: true),
    const AccountView(),
    const CartView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Book'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Cart'),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final HomeViewModel _vm = HomeViewModel();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _vm.addListener(() => setState(() {}));
  }

  Gradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'waiting': return const LinearGradient(colors: [Colors.orangeAccent, Colors.orange], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'ready': return const LinearGradient(colors: [Colors.green, Colors.greenAccent], begin: Alignment.topLeft, end: Alignment.bottomRight);
      case 'in progress': return LinearGradient(colors: [AppColors.primaryBlue, AppColors.lightBlue3], begin: Alignment.topLeft, end: Alignment.bottomRight);
      default: return LinearGradient(colors: [const Color.fromARGB(255, 159, 159, 158), const Color.fromARGB(255, 239, 238, 236)], begin: Alignment.topLeft, end: Alignment.bottomRight); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    List<Map<String, dynamic>> filteredServices = _vm.allServices
        .where((s) => s['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Stack(
      children: [
        const Positioned.fill(child: GeometricBackground()),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HERO BANNER & SEARCH
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180, 
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage('assets/images/welcome_bg.jpg'), fit: BoxFit.cover),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        width: screenWidth * 0.85,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search service',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30), 

                // PROGRESS STATUS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Progress status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy)),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: _getStatusGradient(_vm.currentStatus),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              _vm.currentStatus.toUpperCase(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // SERVICES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy)),
                          if (searchQuery.isEmpty)
                            GestureDetector(
                              onTap: () {
                                // Pass required constructor arguments for standalone viewing
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => const ServicesView(
                                    carRegistration: "N/A", 
                                    carModel: "N/A"
                                  )
                                ));
                              },
                              child: const Text('see all', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      // SERVICES GRID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _vm.previewServices.take(3).map((service) {
                          return Container(
                            width: (screenWidth - 80) / 3,
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: [
                                Icon(service['icon'], size: 35, color: Colors.grey.shade700),
                                const SizedBox(height: 10),
                                Text(
                                  service['name'].toString().split(' ')[0].toLowerCase(),
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}