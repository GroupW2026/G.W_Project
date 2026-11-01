import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../viewmodels/services_viewmodel.dart';
import '../viewmodels/app_state.dart';
import 'cart_view.dart';

class ServicesView extends StatefulWidget {
  final double carMultiplier;
  final String? carImageUrl;
  final String carRegistration;
  final String carModel;

  const ServicesView({
    super.key, 
    this.carMultiplier = 1.0,
    this.carImageUrl,
    required this.carRegistration,
    required this.carModel,
  });

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  late ServicesViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ServicesViewModel(widget.carMultiplier);
    _vm.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text('Select Services', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy)), 
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: AppColors.navy)
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GeometricBackground()),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: _vm.allServices.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                      : ListView.builder(
                          itemCount: _vm.allServices.length,
                          itemBuilder: (context, index) {
                            final service = _vm.allServices[index];
                            final isSelected = appState.selectedServices.any((s) => s['id'] == service['id']);
                            final adjustedPrice = _vm.getAdjustedPrice(double.parse(service['price'].toString()));

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 5))],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                title: Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                                subtitle: Text('R${adjustedPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 15)),
                                trailing: Checkbox(
                                  activeColor: AppColors.primaryBlue,
                                  value: isSelected,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  onChanged: (val) {
                                    appState.toggleService(service, adjustedPrice);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () {
                      // The booking details are already saved in AppState by the BookingView!
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartView()));
                    },
                    child: const Text('View Cart', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}