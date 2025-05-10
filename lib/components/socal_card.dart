import 'package:flutter/material.dart';

class SocialCard extends StatelessWidget {
  final Widget icon;
  final VoidCallback press;

  const SocialCard({
    Key? key,
    required this.icon,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
        child: icon,
      ),
    );
  }
}
