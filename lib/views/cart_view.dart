import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../viewmodels/app_state.dart';
import 'payment_view.dart';
import 'booking_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF), 
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GeometricBackground()),
          SafeArea(
            child: appState.selectedServices.isEmpty 
                ? _buildEmptyCart() 
                : _buildCartWithItems(context, appState),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text('Nothing selected', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Text('Go to Services to choose a wash.', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildCartWithItems(BuildContext context, AppState appState) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: appState.selectedServices.length,
            itemBuilder: (context, index) {
              final service = appState.selectedServices[index];
              return _buildCartItemCard(context, appState, service, index);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navy)),
                  Text('R${appState.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 5),
                  onPressed: () {
                    // --- THE GUARD ---
                    if (appState.hasBookingDetails) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PaymentView(
                          totalAmount: appState.totalPrice, 
                          selectedServices: appState.selectedServices,
                          carImageUrl: appState.carImageUrl,
                          carRegistration: appState.carRegistration!,
                          carModel: appState.selectedCarType!,
                        ), 
                      ));
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Missing Details"),
                          content: const Text("Please book a date, time, and enter your car details before checking out."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingView(isFromNavBar: false)));
                              },
                              child: const Text("Go to Booking"),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Proceed to Checkout', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(BuildContext context, AppState appState, Map<String, dynamic> service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.lightBlue1, borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.local_car_wash, color: AppColors.primaryBlue, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
                const SizedBox(height: 5),
                Text('R${double.parse(service['price'].toString()).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              appState.removeService(index);
            },
          )
        ],
      ),
    );
  }
}