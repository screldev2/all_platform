import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double progress;
  final bool isLoading;

  const LoadingIndicator({super.key, required this.progress, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: LinearProgressIndicator(
          value: progress > 0 ? progress / 100 : null,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF129247)),
        ),
      ),
    );
  }
}
