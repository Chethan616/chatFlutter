import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/widgets/my_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;
    final authProvider = context.watch<AuthenticationProvider>();

    final defaultPinTheme = PinTheme(
        width: 56,
        height: 60,
        textStyle: GoogleFonts.openSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ));

    return Scaffold(
      appBar: MyAppBar(
        title: const Text('OTP Verification'),
        onPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/chat.png',
            fit: BoxFit.cover,
          ),

          // Dark overlay
          Container(color: Colors.black.withOpacity(0.4)),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Verify Your Number',
                          style: GoogleFonts.openSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // OTP Description
                        Text(
                          'Enter the 6-digit code sent to',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          phoneNumber,
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // OTP Input
                        SizedBox(
                          height: 68,
                          child: Pinput(
                            length: 6,
                            controller: controller,
                            focusNode: focusNode,
                            defaultPinTheme: defaultPinTheme,
                            onCompleted: (pin) {
                              setState(() => otpCode = pin);
                              verifyOTPCode(
                                verificationId: verificationId,
                                otpCode: pin,
                              );
                            },
                            focusedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
                                border: Border.all(color: Colors.deepPurple),
                              ),
                            ),
                            errorPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
                                border: Border.all(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Status Indicators
                        if (authProvider.isLoading)
                          const CircularProgressIndicator(
                            color: Colors.deepPurple,
                            strokeWidth: 2,
                          )
                        else if (authProvider.isSuccessful)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        const SizedBox(height: 30),

                        // Resend Code Section
                        if (!authProvider.isLoading)
                          Column(
                            children: [
                              Text(
                                'Didn\'t receive the code?',
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: authProvider.secondsRemaing == 0
                                    ? () => authProvider.resendCode(
                                          context: context,
                                          phone: phoneNumber,
                                        )
                                    : null,
                                child: Text(
                                  'Resend Code',
                                  style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: authProvider.secondsRemaing == 0
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: () async {
        bool userExists = await authProvider.checkUserExists();
        if (userExists) {
          await authProvider.getUserDataFromFireStore();
          await authProvider.saveUserDataToSharedPreferences();
          navigate(userExits: true);
        } else {
          navigate(userExits: false);
        }
      },
    );
  }

  void navigate({required bool userExits}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      userExits ? Constants.homeScreen : Constants.userInformationScreen,
      (route) => false,
    );
  }
}
