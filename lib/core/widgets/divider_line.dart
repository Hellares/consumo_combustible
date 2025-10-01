import 'package:flutter/material.dart';

class DividerLine extends StatelessWidget {
  const DividerLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.black.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.3),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.black.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}