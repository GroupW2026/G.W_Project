import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'register_view.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthViewModel _vm = AuthViewModel();

  void _doLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {}); // Show loading spinner
      
      bool success = await _vm.login(_emailCtrl.text, _passCtrl.text);
      
      setState(() {}); // Stop loading spinner

      if (success && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeView()));
      } else if (mounted) {
        // SHOW THE ERROR TO THE USER
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Check your email/password or verify your email.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.navy)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Login', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailCtrl,
                validator: _vm.validateEmail,
                decoration: InputDecoration(labelText: 'Email', filled: true, fillColor: AppColors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                validator: _vm.validatePassword,
                decoration: InputDecoration(labelText: 'Password', filled: true, fillColor: AppColors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _vm.isLoading ? null : _doLogin,
                  child: _vm.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(color: AppColors.white, fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterView())),
                child: const Text("Don't have an account? Register", style: TextStyle(color: AppColors.navy)),
              )
            ],
          ),
        ),
      ),
    );
  }
}