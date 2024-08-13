import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncwfinder/views/screens/screens.dart';

class NotificationDialog extends StatelessWidget {
  final String name;
  final String age;
  final String city;
  final String country;
  final String profileImage;
  final String profession;
  final String senderId;

  const NotificationDialog({
    Key? key,
    required this.name,
    required this.age,
    required this.city,
    required this.country,
    required this.profileImage,
    required this.profession,
    required this.senderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              const EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              Text(
                "$age years old, $profession",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "$city, $country",
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(UserDetails.routeName, arguments: senderId);
                      },
                      child: const Text('View Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child:
                          const Text('Close', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(45)),
              child: Image.network(profileImage),
            ),
          ),
        ),
      ],
    );
  }
}
