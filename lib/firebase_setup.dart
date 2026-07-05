import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for seiza_kore
/// Web Firebase config (replace with your actual Firebase project config)
const firebaseConfig = {
  'apiKey': 'YOUR_API_KEY',
  'authDomain': 'seiza-kore.firebaseapp.com',
  'projectId': 'seiza-kore',
  'storageBucket': 'seiza-kore.appspot.com',
  'messagingSenderId': 'YOUR_MESSAGING_SENDER_ID',
  'appId': 'YOUR_APP_ID',
};

/// Initialize Firebase with Web-specific configuration
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey'] as String,
      appId: firebaseConfig['appId'] as String,
      messagingSenderId: firebaseConfig['messagingSenderId'] as String,
      projectId: firebaseConfig['projectId'] as String,
      authDomain: firebaseConfig['authDomain'] as String,
      storageBucket: firebaseConfig['storageBucket'] as String,
    ),
  );
}
