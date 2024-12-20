import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTField extends StatelessWidget {
  final TextEditingController textEditingController;
  final IconData? iconData;
  final String? assetRef;
  final String? labelText;
  final bool? isObscure;
  const CustomTField({
    super.key,
    required this.textEditingController,
    this.iconData,
    this.assetRef,
    this.labelText,
    this.isObscure,
  });

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
                padding: EdgeInsets.all(8.sp),
                child: Image.asset(
                  assetRef.toString(),
                ),
              ),
        labelStyle: TextStyle(fontSize: 18.sp, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(color: Colors.grey[900]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.sp),
          borderSide: BorderSide(color: Colors.grey[900]!),
        ),
      ),
    );
  }
}
