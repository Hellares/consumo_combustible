// =============================================
// Connection Status Banner
// Banner que muestra el estado de conexión
// =============================================

import 'package:flutter/material.dart';

class ConnectionStatusBanner extends StatelessWidget {
  final bool isConnected;
  final bool isSubscribed;
  final String? errorMessage;

  const ConnectionStatusBanner({
    super.key,
    required this.isConnected,
    this.isSubscribed = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;
    String message;

    if (errorMessage != null) {
      backgroundColor = Colors.red;
      icon = Icons.error_outline;
      message = errorMessage!;
    } else if (isConnected && isSubscribed) {
      backgroundColor = Colors.green;
      icon = Icons.check_circle_outline;
      message = 'Conectado y rastreando';
    } else if (isConnected) {
      backgroundColor = Colors.orange;
      icon = Icons.cloud_done;
      message = 'Conectado - Presiona Iniciar Tracking';
    } else {
      backgroundColor = Colors.grey;
      icon = Icons.cloud_off;
      message = 'Desconectado';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          if (isConnected)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}