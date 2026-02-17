import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class ExitConfirmationDialog {
  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              contentPadding: const EdgeInsets.all(0),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with gradient background
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppConstants.primaryColor.withValues(alpha: 0.1), AppConstants.primaryColor.withValues(alpha: 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),

                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.exit_to_app_rounded, size: 36, color: AppConstants.primaryColor),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      AppConstants.exitAppTitle,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a), letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      AppConstants.exitAppMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(AppConstants.cancelText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Exit Button
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppConstants.primaryColor, AppConstants.primaryColorDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: AppConstants.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: ElevatedButton(
                              onPressed: () => exit(0),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(AppConstants.exitText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }
}
