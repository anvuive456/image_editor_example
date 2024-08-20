import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_editor_example/screens/main_screen.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart';

final routers = GoRouter(
  initialLocation: '/signin',
  routes: [
    GoRoute(
      path: '/',
      name: 'main',
      builder: (context, state) => MainScreen(),
    ),
    GoRoute(
      path: '/image_editor',
      name: 'image_editor',
      builder: (context, state) => ImageEditor(
        image: state.extra,
        imagePickerOption: const ImagePickerOption(
          pickFromGallery: true,
          captureFromCamera: true,
        ),
      ),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => RegisterScreen(
        actions: [],
      ),
    ),
    GoRoute(
      path: '/signin',
      name: 'signin',
      builder: (context, state) => SignInScreen(
        providers: [
          EmailAuthProvider(),
        ],
        showPasswordVisibilityToggle: true,
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            context.goNamed('main');
          }),
        ],
      ),
    )
  ],
);
