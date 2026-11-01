import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'login_view.dart'; 

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation setup for fade in/out
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); 

    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. DARK OVERLAY (So text is readable)
          Positioned.fill(
            child: Container(
              color: AppColors.navy.withOpacity(0.5), 
            ),
          ),

          // 3. MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top WELCOME Text
                  const Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: AppColors.white,
                    ),
                  ),
                  
                  // Center Fading Text
                  FadeTransition(
                    opacity: _animation,
                    child: const Text(
                      'LifeStyle Square\nCarwash',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38, 
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(blurRadius: 15.0, color: Colors.black45, offset: Offset(0, 4))
                        ]
                      ),
                    ),
                  ),

                  // Bottom Blue Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue, // From your palette
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to Login Screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Let's GO ",
                            style: TextStyle(
                              color: AppColors.white, 
                              fontSize: 20, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, color: AppColors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}