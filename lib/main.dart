import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_example/firebase_options.dart';
import 'package:image_editor_example/routes.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: routers,
      ),
    );
  }, (error, stack) {
    print(error);
    print(stack);
  });
}
