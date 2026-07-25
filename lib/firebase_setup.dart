import 'package:firebase_core/firebase_core.dart';

/// Firebase project: apps2-752cb
/// Android app is configured via android/app/google-services.json
/// (package: com.petitworksapps.seizakore). No Web app has been
/// registered in the Firebase console yet — add one and fill in
/// webFirebaseConfig below before enabling Firebase on Web.
const webFirebaseConfig = {
  'apiKey': '',
  'authDomain': 'apps2-752cb.firebaseapp.com',
  'projectId': 'apps2-752cb',
  'storageBucket': 'apps2-752cb.firebasestorage.app',
  'messagingSenderId': '946448575860',
  'appId': '',
};

/// Initialize Firebase.
/// On Android/iOS, options are omitted so the native SDK reads the
/// platform config file (google-services.json / GoogleService-Info.plist)
/// automatically. On Web, explicit options are required; until a Web
/// app is registered in the console, initialization is skipped there.
Future<void> initializeFirebase() async {
  final hasWebConfig = webFirebaseConfig['apiKey']!.isNotEmpty &&
      webFirebaseConfig['appId']!.isNotEmpty;

  await Firebase.initializeApp(
    options: hasWebConfig
        ? FirebaseOptions(
            apiKey: webFirebaseConfig['apiKey']!,
            appId: webFirebaseConfig['appId']!,
            messagingSenderId: webFirebaseConfig['messagingSenderId']!,
            projectId: webFirebaseConfig['projectId']!,
            authDomain: webFirebaseConfig['authDomain'],
            storageBucket: webFirebaseConfig['storageBucket'],
          )
        : null,
  );
}
