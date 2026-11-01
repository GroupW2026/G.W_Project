import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != originalPassword) return 'Passwords do not match';
    return null;
  }

  // --- REAL SUPABASE LOGIN ---
  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      print("LOGIN SUCCESSFUL!");
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("========== LOGIN ERROR ==========");
      print(e.toString());
      print("=================================");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- REAL SUPABASE REGISTER ---
  Future<bool> register(String fullName, String email, String phone, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Create Auth User
      final response = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      // Check if Supabase actually created the user
      if (response.user == null) {
        print("========== REGISTER ERROR: USER IS NULL ==========");
        isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Save details to the 'profiles' table
      try {
        await Supabase.instance.client.from('profiles').insert({
          'id': response.user!.id,
          'full_name': fullName,
          'phone': phone,
          'role': 'customer',
        });
        print("PROFILE SAVED SUCCESSFULLY!");
      } catch (profileError) {
        print("========== PROFILE SAVE ERROR ==========");
        print(profileError.toString());
        print("========================================");
      }
      
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("========== SUPABASE REGISTER ERROR ==========");
      print(e.toString());
      print("=============================================");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}