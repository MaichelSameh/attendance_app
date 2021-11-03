import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_controller.dart';
import '../models/size.dart';

class ProfilePicture extends StatelessWidget {
  late final Color _color;
  late final String? _name;
  late final String? _role;
  late final String? _imageUrl;
  ProfilePicture({
    required Color color,
    String? name,
    String? role,
    String? imageURL,
  }) {
    this._color = color;
    this._imageUrl = imageURL;
    this._name = name;
    this._role = role;
  }
  @override
  Widget build(BuildContext context) {
    Size _size = Size(context);
    return GestureDetector(
      child: Container(
        height: _size.height(173),
        child: Column(
          children: [
            Container(
              width: _size.width(96),
              height: _size.width(96),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_size.width(48)),
                child: _imageUrl == null
                    ? GetBuilder<UserController>(builder: (controller) {
                        return Image.file(
                          File(controller.currentUser.profileImage),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) {
                            return Image.asset(
                              "assets/images/profile_avatar.png",
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      })
                    : Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) {
                          return Image.asset(
                            "assets/images/profile_avatar.png",
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),
            ),
            SizedBox(height: _size.height(13)),
            Text(
              _name == null
                  ? Get.find<UserController>().currentUser.name
                  : _name!,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: _color,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              _role == null
                  ? Get.find<UserController>().currentUser.role
                  : _role!,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: _color.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
