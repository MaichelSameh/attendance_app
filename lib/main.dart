import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/controllers.dart';
import 'screens/screens.dart';
import 'services/handle_notifications.dart';

Future<void> handleBackgroundNotification(RemoteMessage message) async {
  final RemoteNotification? notification = message.notification;
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (notification!.body!.isCaseInsensitiveContains("New") &&
      notification.body!.isCaseInsensitiveContains("added")) {
    int value = pref.getInt("manager_notification_count") ?? 0;
    pref.setInt("manager_notification_count", ++value);
  } else {
    int value = pref.getInt("employee_notification_count") ?? 0;
    pref.setInt("employee_notification_count", ++value);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  HandleNotification.initialize();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);

  Get.put<HomeController>(HomeController());
  Get.put<AppLocalizationController>(AppLocalizationController.empty());
  Get.put<LoginController>(LoginController());
  Get.put<UserController>(UserController());
  Get.put<ManagerHomeController>(ManagerHomeController());

  Get.find<HomeController>().initNotificationCount();
  Get.find<ManagerHomeController>().initNotificationCount();

  await Get.find<AppLocalizationController>().getAppLocale();

  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppLocalizationController>(
      builder: (appLocalizationController) => GetMaterialApp(
        initialRoute: SplashScreen.route_name,
        routes: {
          //screens for employee section
          AddReportScreen.route_name: (_) => AddReportScreen(),
          AttendanceDetailsScreen.route_name: (_) => AttendanceDetailsScreen(),
          AttendanceScreen.route_name: (_) => AttendanceScreen(),
          CalenderScreen.route_name: (_) => CalenderScreen(),
          ClientVisitDetailsScreen.route_name: (_) =>
              ClientVisitDetailsScreen(),
          ClientVisitScreen.route_name: (_) => ClientVisitScreen(),
          HomeScreen.route_name: (_) => HomeScreen(),
          NotificationScreen.route_name: (_) => NotificationScreen(),
          PermissionDetailsScreen.route_name: (_) => PermissionDetailsScreen(),
          PermissionScreen.route_name: (_) => PermissionScreen(),
          ReportDetailsScreen.route_name: (_) => ReportDetailsScreen(),
          ReportScreen.route_name: (_) => ReportScreen(),
          RequestNewPermissionScreen.route_name: (_) =>
              RequestNewPermissionScreen(),
          RequestNewVacationScreen.route_name: (_) =>
              RequestNewVacationScreen(),
          VacationDetailsScreen.route_name: (_) => VacationDetailsScreen(),
          VacationScreen.route_name: (_) => VacationScreen(),
          //screens for the manager section
          ManagerAttendanceDetailsScreen.route_name: (_) =>
              ManagerAttendanceDetailsScreen(),
          ManagerAttendanceScreen.route_name: (_) => ManagerAttendanceScreen(),
          ManagerClientVisitDetailsScreen.route_name: (_) =>
              ManagerClientVisitDetailsScreen(),
          ManagerClientVisitScreen.route_name: (_) =>
              ManagerClientVisitScreen(),
          ManagerHomeScreen.route_name: (_) => ManagerHomeScreen(),
          ManagerPermissionDetailsScreen.route_name: (_) =>
              ManagerPermissionDetailsScreen(),
          ManagerPermissionScreen.route_name: (_) => ManagerPermissionScreen(),
          ManagerReportDetailsScreen.route_name: (_) =>
              ManagerReportDetailsScreen(),
          ManagerReportScreen.route_name: (_) => ManagerReportScreen(),
          ManagerVacationDetailsScreen.route_name: (_) =>
              ManagerVacationDetailsScreen(),
          ManagerVacationScreen.route_name: (_) => ManagerVacationScreen(),
          EmployeeScreen.route_name: (_) => EmployeeScreen(),
          RequestsScreen.route_name: (_) => RequestsScreen(),
          //common screens between employee and manager sections
          LoginScreen.route_name: (_) => LoginScreen(),
          SplashScreen.route_name: (_) => SplashScreen(),
          ProfileScreen.route_name: (_) => ProfileScreen(),
          NoConnectionScreen.route_name: (_) => NoConnectionScreen(),
          SettingScreen.route_name: (_) => SettingScreen(),
          ChangeLanguageScreen.route_name: (_) => ChangeLanguageScreen(),
          AddNewBranchScreen.route_name: (_) => AddNewBranchScreen(),
          ChangePasswordScreen.route_name: (_) => ChangePasswordScreen(),
        },
        locale: appLocalizationController.currentLocale,
        supportedLocales: appLocalizationController.locales,
        localizationsDelegates: [
          AppLocalizationController.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromRGBO(249, 248, 251, 1),
          canvasColor: Colors.blue,
          textTheme: TextTheme(
            bodyText1: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          fontFamily:
              appLocalizationController.currentLocale.languageCode == "ar"
                  ? "Almarai"
                  : "Montserrat",
        ),
      ),
    );
  }
}
