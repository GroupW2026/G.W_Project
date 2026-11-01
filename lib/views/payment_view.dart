import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../viewmodels/app_state.dart';
import 'home_view.dart';

class PaymentView extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> selectedServices;
  final String? carImageUrl;
  final String carRegistration;
  final String carModel;

  const PaymentView({
    super.key, 
    required this.totalAmount, 
    required this.selectedServices,
    this.carImageUrl,
    this.carRegistration = "Unknown", 
    this.carModel = "Standard",
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  
  bool isProcessing = false;

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isProcessing = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      String servicesString = widget.selectedServices.map((s) => s['name']).join(", ");
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      String displayName = "Guest";
      String displayEmail = "N/A";
      String displayPhone = "N/A";

      if (currentUser != null) {
        displayEmail = currentUser.email ?? "N/A";
        final profileData = await Supabase.instance.client.from('profiles').select('full_name, phone').eq('id', currentUser.id).maybeSingle();
        if (profileData != null) {
          displayName = profileData['full_name'] ?? "Customer";
          displayPhone = profileData['phone'] ?? "N/A";
        }
      }

      final response = await Supabase.instance.client.from('bookings').insert({
        'customer_id': currentUser?.id,
        'customer_name': displayName,
        'customer_email': displayEmail, 
        'customer_phone': displayPhone, 
        'service_type': servicesString,
        'car_registration': widget.carRegistration,
        'car_model': widget.carModel,
        'amount_paid': widget.totalAmount,
        'status': 'Waiting',
        'car_image_url': widget.carImageUrl, 
        'booking_date': appState.selectedDate, 
        'booking_time': appState.selectedTime, 
        'valuables': appState.valuablesComment, 
      }).select();

      int newTicketNumber = response[0]['id']; 

      if (!mounted) return;
      setState(() => isProcessing = false);

      Provider.of<AppState>(context, listen: false).clearCart();
      _showConfirmationDialog(newTicketNumber);

    } catch (e) {
      if (!mounted) return;
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showConfirmationDialog(int ticketNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(color: Color(0xFF00A859), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 20),
              const Text('Your Booking is Confirmed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87), textAlign: TextAlign.center),
              const SizedBox(height: 15),
              const Text('Your Ticket Number :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('$ticketNumber', style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Colors.black54)),
              const SizedBox(height: 20),
              const Text('Thank you for booking with us.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A859), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeView()), (route) => false);
                  },
                  child: const Text('Track Your Status', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GeometricBackground()),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))]),
                            child: Column(
                              children: [
                                ...widget.selectedServices.map((service) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(service['name'], style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
                                        Text('R${double.parse(service['price'].toString()).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                const Divider(height: 25),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.navy)),
                                    Text('R${widget.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text('Payment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))]),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _cardNumberCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: 'Card Number (Demo)', hintText: '0000 0000 0000 0000', prefixIcon: const Icon(Icons.credit_card, color: AppColors.primaryBlue), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                  validator: (value) {
                                    if (value == null || value.isEmpty || value.length < 16) return 'Please enter a valid 16-digit demo card';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _expiryCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(labelText: 'Expiry Date', hintText: 'MM/YY', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                        validator: (value) => value!.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _cvvCtrl,
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                        decoration: InputDecoration(labelText: 'CVV', hintText: '123', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                        validator: (value) => value!.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))]),
                  child: SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 5),
                      onPressed: isProcessing ? null : _processPayment,
                      child: isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Text('Pay Now - R${widget.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}