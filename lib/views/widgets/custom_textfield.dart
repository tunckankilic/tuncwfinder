import 'package:flutter/material.dart';

class CustomTField extends StatelessWidget {
  final TextEditingController textEditingController;
  final IconData? iconData;
  final String? assetRef;
  final String? labelText;
  final bool? isObscure;
  const CustomTField({
    Key? key,
    required this.textEditingController,
    this.iconData,
    this.assetRef,
    this.labelText,
    this.isObscure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      obscureText: isObscure ?? false,
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: iconData != null
            ? Icon(iconData)
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  assetRef.toString(),
                ),
              ),
        labelStyle: const TextStyle(fontSize: 18, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[900]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[900]!),
        ),
      ),
    );
  }
}
