import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  String currentStatus = "No Active Booking";
  String currentTicket = "-";
  
  final List<Map<String, dynamic>> allServices = [
    {"name": "Full Package", "price": "R150", "icon": Icons.star_rounded},
    {"name": "Interior Only", "price": "R90", "icon": Icons.chair_rounded},
    {"name": "Exterior Wash", "price": "R110", "icon": Icons.water_drop_rounded},
    {"name": "Engine Wash", "price": "R150", "icon": Icons.settings_rounded},
    {"name": "Leather Care", "price": "R200", "icon": Icons.diamond_rounded},
    {"name": "Tyre Shine", "price": "R50", "icon": Icons.circle_rounded},
  ];

  List<Map<String, dynamic>> get previewServices => allServices.take(4).toList();

  HomeViewModel() {
    _fetchCurrentStatus(); 
    _listenToStatusChanges(); 
  }

  // Fetch the current status when they open the app
  Future<void> _fetchCurrentStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('bookings')
          .select()
          .eq('customer_id', user.id)
          .neq('status', 'Completed') // Change this if you use a different word for history
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        String dbStatus = response['status'];
        
        // If the status is Ready, we show it. If we wanted to hide completed cars, we'd handle it here.
        currentStatus = dbStatus;
        currentTicket = "#${response['id']}";
        notifyListeners();
      } else {
        currentStatus = "No Active Booking";
        currentTicket = "-";
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching status: $e");
    }
  }

  // Listen to real-time changes from ASP.NET
  void _listenToStatusChanges() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    Supabase.instance.client
        .channel('public:bookings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            final newRecord = payload.newRecord;
            
            if (newRecord.isNotEmpty && 
                newRecord['customer_id'] == user.id && 
                newRecord['status'] != null) {
              
              // THE FIX: Just display the status directly from the database
              currentStatus = newRecord['status'];
              currentTicket = "#${newRecord['id']}";
              
              notifyListeners(); 
            }
          },
        )
        .subscribe();
  }
}