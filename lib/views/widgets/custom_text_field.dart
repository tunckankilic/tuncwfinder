import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController? editingController;
  final IconData? iconData;
  final String? assetRef;
  final String? labelText;
  final bool? isObscure;

  const CustomTextFieldWidget({
    super.key,
    this.editingController,
    this.iconData,
    this.assetRef,
    this.labelText,
    this.isObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: editingController,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: iconData != null
            ? Icon(iconData)
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(assetRef.toString()),
              ),
        labelStyle: TextStyle(
          fontSize: 18.sp,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      obscureText: isObscure!,
    );
  }
}
