import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // <-- ADDED
import '../utils/app_colors.dart';
import '../viewmodels/app_state.dart'; // <-- ADDED
import 'welcome_view.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  String fullName = "Loading...";
  String phone = "Loading...";
  String email = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        email = user.email ?? "No email";
        
        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name, phone')
            .eq('id', user.id)
            .maybeSingle();

        setState(() {
          if (data != null) {
            fullName = data['full_name'] ?? "Customer";
            phone = data['phone'] ?? "No phone";
          } else {
            fullName = "Profile Missing in DB";
            phone = "Please register again";
          }
          isLoading = false;
        });
      } else {
        setState(() {
          fullName = "Not Logged In";
          email = "Please log in to view profile";
          phone = "-";
          isLoading = false;
        });
      }
    } catch (e) {
      print("PROFILE FETCH ERROR: $e");
      setState(() {
        fullName = "Error loading profile";
        isLoading = false;
      });
    }
  }

  // --- REAL LOGOUT (UPDATED TO CLEAR MEMORY) ---
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    
    if (mounted) {
      // CLEAR ALL GLOBAL APP STATE MEMORY HERE
      Provider.of<AppState>(context, listen: false).clearCart();
      
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => const WelcomeView()), 
        (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy)),
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GeometricBackground()),

          SafeArea(
            child: isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45, 
                          backgroundColor: AppColors.lightBlue2, 
                          child: Icon(Icons.person, size: 50, color: AppColors.navy)
                        ),
                        const SizedBox(height: 15),
                        Text(
                          fullName, 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.navy)
                        ),
                        Text(
                          email, 
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600)
                        ),
                        
                        const SizedBox(height: 30),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.phone, "Phone Number", phone),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        _buildMenuSection('Manage', ['My Bookings', 'My Payments', 'My Vehicles']),
                        const SizedBox(height: 20),
                        _buildMenuSection('Settings', ['Account Settings', 'Notification Settings', 'Feedback']),
                        
                        const SizedBox(height: 30),
                        
                        SizedBox(
                          width: double.infinity, height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 5
                            ),
                            onPressed: _logout,
                            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.lightBlue1, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
          ],
        )
      ],
    );
  }

  Widget _buildMenuSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.navy)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: Column(
            children: items.map((e) => ListTile(
              title: Text(e, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              onTap: () {},
            )).toList(),
          ),
        )
      ],
    );
  }
}