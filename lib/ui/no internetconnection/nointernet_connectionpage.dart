import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class NoInternetPage extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetPage({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Lottie animation from assets/lottie/
              SizedBox(
                width: 220,
                height: 220,
                child: Lottie.asset(
                  'assets/lottie/Lonely 404 .json',
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if Lottie file fails to load
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 58,
                        color: Colors.teal,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No Internet Connection',
                style: AppTextStyles.h3(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Check your Wi-Fi or mobile data\nsettings and try again.',
                style: AppTextStyles.subtitle().copyWith(height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ✅ Retry button — calls back into ConnectivityCubit.checkConnection()

            ],
          ),
        ),
      ),
    );
  }
}