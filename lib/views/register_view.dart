import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_colors.dart';
import 'home_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String fullName = "${_nameCtrl.text.trim()} ${_surnameCtrl.text.trim()}";

      // 1. Try to create the user in Supabase Auth
      print("TRYING TO REGISTER: ${_emailCtrl.text}");
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      print("AUTH RESPONSE: ${response.user?.id}");

      if (response.user != null) {
        // 2. Try to save to the profiles table
        print("USER CREATED! NOW SAVING TO PROFILES...");
        try {
          await Supabase.instance.client.from('profiles').insert({
            'id': response.user!.id,
            'full_name': fullName,
            'phone': _phoneCtrl.text,
            'role': 'customer',
          });
          print("PROFILE SAVED SUCCESSFULLY!");
        } catch (profileError) {
          print("PROFILE TABLE ERROR: $profileError");
        }
      } else {
        print("USER IS NULL. SUPABASE DID NOT CREATE THE USER.");
      }

      setState(() => isLoading = false);
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const HomeView()), 
          (route) => false
        );
      }
    } catch (e) {
      print("========== FATAL ERROR ==========");
      print(e.toString());
      print("=================================");
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: AppColors.navy)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Register', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 30),
              
              _buildField('Name', _nameCtrl),
              const SizedBox(height: 15),
              _buildField('Surname', _surnameCtrl),
              const SizedBox(height: 15),
              _buildField('Email', _emailCtrl, isEmail: true),
              const SizedBox(height: 15),
              _buildField('Phone Number', _phoneCtrl, isPhone: true),
              const SizedBox(height: 15),
              _buildField('Password', _passCtrl, isPassword: true),
              const SizedBox(height: 15),
              _buildField('Confirm Password', _confirmPassCtrl, isPassword: true),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: isLoading ? null : _registerUser,
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register', style: TextStyle(color: AppColors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isPassword = false, bool isEmail = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (isEmail && !value.contains('@')) return 'Invalid email';
        if (isPassword && value.length < 6) return 'Minimum 6 characters';
        return null;
      },
      decoration: InputDecoration(
        labelText: label, 
        filled: true, 
        fillColor: AppColors.white, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
    );
  }
}