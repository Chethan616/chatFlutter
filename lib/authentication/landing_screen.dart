import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAuthentication();
    super.initState();
  }

  void checkAuthentication() async {
    final authProvider = context.read<AuthenticationProvider>();
    bool isAuthenticated = await authProvider.checkAuthenticationState();

    navigate(isAuthenticated: isAuthenticated);
  }

  navigate({required bool isAuthenticated}) {
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 300,
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: [
              Lottie.asset(AssetsManager.loading),
              // const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
