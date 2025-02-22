
/**
 * @file Welcome screen for the Illit app
 * @description
 * This file contains the WelcomeScreen widget, which serves as the initial
 * screen of the app. It displays a welcome message with a fade animation,
 * member avatars, and navigates to WebhookSetupScreen or GameListScreen.
 *
 * Key features:
 * - Fade animation for the welcome text
 * - Display of member avatars in a wrap layout
 * - Checks webhook and navigates accordingly after 5 seconds
 *
 * @dependencies
 * - flutter/material.dart: For UI components and animations
 * - screens/game_list_screen.dart: For navigation target
 * - screens/webhook_setup_screen.dart: For webhook setup
 * - services/api_service.dart: For webhook check
 */

import 'package:flutter/material.dart';
import 'game_list_screen.dart';
import 'webhook_setup_screen.dart';
import '../services/api_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () async {
      if (mounted) {
        try {
          final webhook = await _apiService.getWebhook();
          if (webhook.isEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WebhookSetupScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GameListScreen()),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao verificar webhook: $e')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WebhookSetupScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8C1CC), Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'ILLIT    아일릿',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildMemberAvatar('Moka', 'assets/images/moka.png'),
                  _buildMemberAvatar('Iroha', 'assets/images/iroha.png'),
                  _buildMemberAvatar('Wonhee', 'assets/images/wonhee.png'),
                  _buildMemberAvatar('Minju', 'assets/images/minju.png'),
                  _buildMemberAvatar('Yunah', 'assets/images/yunah.png'),
                ],
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB2EBF2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(String name, String imagePath) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
