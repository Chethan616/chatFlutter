import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/utilities/assets_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final conroller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  // New state to track loading completion
  bool isLoadingComplete = false;
  bool showGreenTick = false;

  @override
  void dispose() {
    conroller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // get the arguments
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
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Verification',
                  style: GoogleFonts.openSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Enter the 6 digit code sent to the number',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  phoneNumber,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: Pinput(
                    length: 6,
                    controller: conroller,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    onCompleted: (pin) {
                      setState(() {
                        otpCode = pin;
                      });
                      // verify otp code
                      verifyOTPCode(
                        verificationId: verificationId,
                        otpCode: otpCode!,
                      );
                    },
                    focusedPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                authProvider.isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            AssetsManager
                                .circularLoading, // Your Lottie animation asset
                            height: 60, // Optional: Specify height
                            width: 60, // Optional: Specify width
                            fit: BoxFit
                                .contain, // Ensures the animation fits within the bounds
                          ),
                          const SizedBox(height: 10),
                        ],
                      )
                    : SizedBox.shrink(),
                // Fade and Scale effect for the green tick after loading completes
                AnimatedOpacity(
                  opacity: showGreenTick ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedScale(
                    scale: showGreenTick ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      height: 40,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                authProvider.isLoading
                    ? const SizedBox.shrink()
                    : const SizedBox(height: 20),
                Text('didn\'t receive the code?',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 5),
                TextButton(
                    onPressed: () {
                      // TODO resend otp code
                    },
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurpleAccent,
                      ),
                    )),
              ],
            ),
          ),
        ),
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
        setState(() {
          showGreenTick = true; // Trigger the transition effect
        });

        // 1. check if the user exists in firestore
        bool userExists = await authProvider.checkUserExists();

        if (userExists) {
          // 2. if user exists, navigate to the home screen
          await authProvider.getUserDataFromFirestore();
          await authProvider.saveUserDataToSharedPreferences();
          navigate(userExists: true);
        } else {
          // 3. if user does not exist, navigate to the user information screen
          navigate(userExists: false);
        }
      },
    );
  }

  void navigate({required bool userExists}) {
    if (userExists) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
    } else {
      Navigator.pushNamed(
        context,
        Constants.userInformationScreen,
      );
    }
  }
}
