import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../const/const_data.dart';
import '../controllers/controllers.dart';
import '../controllers/login_controller.dart';
import '../models/size.dart';
import '/screens/screens.dart';
import 'authentication_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String route_name = "splash_screen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    //creating the timer for the splash screen to load the data and to show the company icon
    Timer(
      Duration(seconds: 2),
      () async {
        final ConnectivityResult currentConnectionState =
            await Connectivity().checkConnectivity();
        if (currentConnectionState == ConnectivityResult.none) {
          Navigator.of(context)
              .pushReplacementNamed(NoConnectionScreen.route_name,
                  arguments: (BuildContext context) async {
            final ConnectivityResult currentConnectionState =
                await Connectivity().checkConnectivity();
            if (currentConnectionState != ConnectivityResult.none)
              Navigator.of(context).pushReplacementNamed(
                  //trying to auto login the current user without any extra data
                  await Get.find<LoginController>().tryAutoLogin()
                      ? HomeScreen.route_name
                      : LoginScreen.route_name);
          });
        } else {
          Navigator.of(context).pushReplacementNamed(
              //trying to auto login the current user without any extra data
              await Get.find<LoginController>().tryAutoLogin().catchError((_) {
            return false;
          })
                  ? HomeScreen.route_name
                  : LoginScreen.route_name);
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = new Size(context);
    //creating the scaffold for the splash screen
    //this scaffold will contains the logo and the name of the company
    //and a linear gradient to make a good view
    return Scaffold(
      //creating a container to hold the screen components
      body: Container(
        //assigning the width to get the entire screen
        width: double.infinity,
        //assigning the height to get the entire screen
        height: double.infinity,
        //adding the box decoration to decorate the container
        //specificity to create the gradient view
        //note that because we are using the gradient view you can't add a color to the container
        decoration: BoxDecoration(
          //creating the gradient view to start from the screen's top center
          //and ends on the screen's bottom center
          gradient: LinearGradient(
            //importing the colors from the const data class
            colors: ConstData.green_gradient,
            //setting the start point to the top center
            begin: Alignment.topCenter,
            //setting the end point to the bottom center
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder(
          //getting back the image path from the shared preferences
          future: Get.find<LoginController>().getCompanyData(),
          builder: (ctx, snapshot) {
            //showing a progress indicator while in the request is in progress
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container();
            if (snapshot.hasData) {
              //extracting the data after fetching it from the shared preferences
              Map<String, String> data = snapshot.data as Map<String, String>;
              //showing the two logos in vertical view
              return Column(
                children: [
                  //dividing the screen into six pieces and dividing them as following
                  //three flex before the company logo to center it
                  Spacer(flex: 3),
                  //showing up the company logo
                  Hero(
                    tag: "logo",
                    child: data["logo"]!.endsWith("svg")
                        ? SvgPicture.file(
                            File(data["logo"]!),
                            height: _size.height(66),
                            width: _size.width(196),
                          )
                        : Image.file(
                            File(data["logo"]!),
                            height: _size.height(66),
                          ),
                  ),
                  //getting two pieces between the two logos
                  Spacer(flex: 2),
                  //showing the saudi 2030 vision up
                  SvgPicture.asset(
                    "assets/logos/vision_logo.svg",
                    height: _size.height(98),
                    width: _size.width(98),
                  ),
                  //adding one piece to the bottom
                  Spacer(),
                ],
              );
            }
            //showing an empty container in case we don't have any data to show
            return Container();
          },
        ),
      ),
    );
  }
}
