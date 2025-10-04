import 'package:flutter/material.dart';

class SnackBarHelper {
  // Métodos originales (para uso síncrono)
  static void showSuccess(BuildContext context, String message) {
    _showSuccessWithMessenger(ScaffoldMessenger.of(context), message);
  }

  static void showError(BuildContext context, String message) {
    _showErrorWithMessenger(ScaffoldMessenger.of(context), message);
  }

  static void showInfo(BuildContext context, String message) {
    _showInfoWithMessenger(ScaffoldMessenger.of(context), message);
  }

  static void showWarning(BuildContext context, String message) {
    _showWarningWithMessenger(ScaffoldMessenger.of(context), message);
  }

  // ✅ NUEVOS: Métodos para usar después de async
  static void showSuccessWithMessenger(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    _showSuccessWithMessenger(messenger, message);
  }

  static void showErrorWithMessenger(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    _showErrorWithMessenger(messenger, message);
  }

  static void showInfoWithMessenger(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    _showInfoWithMessenger(messenger, message);
  }

  static void showWarningWithMessenger(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    _showWarningWithMessenger(messenger, message);
  }

  // Implementaciones privadas
  static void _showSuccessWithMessenger(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void _showErrorWithMessenger(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void _showInfoWithMessenger(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void _showWarningWithMessenger(
    ScaffoldMessengerState messenger,
    String message,
  ) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}