import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String text; // Nombre o texto del que sacamos la inicial
  final double size;
  final String? imageUrl; // ✅ Imagen opcional
  final List<Color>? colors;
  final double fontSize;

  const AvatarCircle({
    super.key,
    required this.text,
    this.size = 20,
    this.imageUrl,
    this.colors,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = text.isNotEmpty ? text[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: colors != null
            ? LinearGradient(
                colors: colors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.blue[400]!,
                  Colors.blue[600]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                displayText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
