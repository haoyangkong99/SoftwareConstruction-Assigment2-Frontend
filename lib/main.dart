import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/route.locator.dart';
import 'package:utmletgo/app/route.router.dart';
import 'package:utmletgo/constants/theme.dart';
import 'package:utmletgo/firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  try {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey =
        'pk_test_51LYAgkHVnOUtb8pyRPf20dBuNZOHvphAx3YFxqrdcQJHlk0LjwdDes6vaaggVaPFkteJx36RhZdfLZYPzwkqAWOt00uMMgv6n5';
    Stripe.instance.applySettings();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await setupLocator();
    runApp(MaterialApp(
      title: 'UTM Let Go',
      theme: theme(),
      debugShowCheckedModeBanner: false,
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
    ));
  } catch (e) {}
}
