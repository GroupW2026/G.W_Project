import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  List<Map<String, dynamic>> selectedServices = [];
  double totalPrice = 0.0;

  String? selectedDate;
  String? selectedTime;
  String? selectedCarType;
  String? carRegistration;
  String? carImageUrl;
  double carMultiplier = 1.0;
  String valuablesComment = "";

  // This is what cart_view is looking for!
  bool get hasBookingDetails {
    return selectedDate != null && 
           selectedTime != null && 
           selectedCarType != null && 
           carRegistration != null && 
           carImageUrl != null;
  }

  void toggleService(Map<String, dynamic> service, double adjustedPrice) {
    var serviceCopy = Map<String, dynamic>.from(service);
    serviceCopy['price'] = adjustedPrice.toString();
    int index = selectedServices.indexWhere((s) => s['id'] == serviceCopy['id']);
    if (index >= 0) {
      selectedServices.removeAt(index);
    } else {
      selectedServices.add(serviceCopy);
    }
    calculateTotal();
  }

  void removeService(int index) {
    selectedServices.removeAt(index);
    calculateTotal();
  }

  void calculateTotal() {
    totalPrice = selectedServices.fold(0, (sum, item) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      return sum + price;
    });
    notifyListeners();
  }

  void clearCart() {
    selectedServices.clear();
    totalPrice = 0.0;
    selectedDate = null;
    selectedTime = null;
    selectedCarType = null;
    carRegistration = null;
    carImageUrl = null;
    carMultiplier = 1.0;
     
    notifyListeners();
  }
}