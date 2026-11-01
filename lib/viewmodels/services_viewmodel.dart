import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> allServices = [];
  List<Map<String, dynamic>> selectedServices = [];
  double carMultiplier = 1.0; // Comes from Booking Page

  ServicesViewModel(this.carMultiplier) {
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      final data = await Supabase.instance.client.from('services').select();
      allServices = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  void toggleService(Map<String, dynamic> service) {
    if (selectedServices.any((s) => s['id'] == service['id'])) {
      selectedServices.removeWhere((s) => s['id'] == service['id']);
    } else {
      selectedServices.add(service);
    }
    notifyListeners();
  }

  // Adjust price based on the car type selected
  double getAdjustedPrice(double basePrice) {
    return basePrice * carMultiplier;
  }
}