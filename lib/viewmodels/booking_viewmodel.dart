import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

class BookingViewModel extends ChangeNotifier {
  String? selectedDate;
  String? selectedTime;
  String selectedCarType = 'VW Polo / Vivo (Hatchback)';
  
  final Map<String, double> carTypes = {
    'VW Polo / Vivo (Hatchback)': 1.0,
    'Toyota Starlet / Suzuki Swift (Small)': 0.9,
    'Toyota Hilux / Ford Ranger (Bakkie)': 1.1,
    'Toyota Fortuner / SUV': 1.15,
    'BMW 3 Series / Mercedes C-Class (Luxury)': 1.2,
  };

  Uint8List? carImageBytes; 
  String valuablesComment = "";

  final List<String> allTimeSlots = ['08:00 AM', '10:00 AM', '12:00 PM', '14:00 PM'];
  Map<String, List<String>> bookedSlots = {};

  BookingViewModel() {
    fetchBookedSlots();
  }

  Future<void> fetchBookedSlots() async {
    try {
      final response = await Supabase.instance.client
          .from('bookings')
          .select('booking_date, booking_time') 
          .neq('status', 'Ready'); 

      bookedSlots.clear();
      for (var row in response) {
        String? dateStr = row['booking_date'];
        String? timeStr = row['booking_time'];
        if (dateStr != null && timeStr != null) {
          if (!bookedSlots.containsKey(dateStr)) bookedSlots[dateStr] = [];
          bookedSlots[dateStr]!.add(timeStr);
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching slots: $e");
    }
  }

  bool isTimeBooked(String date, String time) {
    return bookedSlots[date]?.contains(time) ?? false;
  }

  bool isDateFullyBooked(String date) {
    final bookedTimes = bookedSlots[date] ?? [];
    return bookedTimes.length >= allTimeSlots.length;
  }

  void selectDate(String date) {
    DateTime parsedDate = DateFormat('dd MMM').parse(date);
    parsedDate = DateTime(DateTime.now().year, parsedDate.month, parsedDate.day);
    selectedDate = DateFormat('yyyy-MM-dd').format(parsedDate); 
    selectedTime = null; 
    notifyListeners();
  }

  void selectTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  Future<bool> checkIfSlotStillAvailable() async {
    try {
      final response = await Supabase.instance.client
          .from('bookings')
          .select('id')
          .eq('booking_date', selectedDate!)
          .eq('booking_time', selectedTime!)
          .neq('status', 'Ready'); 
      return response.isEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      carImageBytes = await pickedFile.readAsBytes();
      notifyListeners();
    }
  }

  Future<String?> uploadImage() async {
    if (carImageBytes == null) return null;
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Supabase.instance.client.storage.from('car_images').uploadBinary(fileName, carImageBytes!);
      return Supabase.instance.client.storage.from('car_images').getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }
}