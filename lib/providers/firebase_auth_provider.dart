import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Auth User model
class AuthUser {
  final String uid;
  final String? email;
  final bool isAnonymous;
  final String? displayName;

  const AuthUser({
    required this.uid,
    this.email,
    required this.isAnonymous,
    this.displayName,
  });

  factory AuthUser.fromFirebase(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
      displayName: user.displayName,
    );
  }
}

/// Current user stream provider
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final authStream = FirebaseAuth.instance.authStateChanges();
  return authStream.map((user) => user != null ? AuthUser.fromFirebase(user) : null);
});

/// Get current user (async)
final currentUserProvider = FutureProvider<AuthUser?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  return user != null ? AuthUser.fromFirebase(user) : null;
});

/// Sign in anonymously
final signInAnonymouslyProvider = FutureProvider<AuthUser>((ref) async {
  final result = await FirebaseAuth.instance.signInAnonymously();
  return AuthUser.fromFirebase(result.user!);
});

/// Sign in with email and password
final signInWithEmailProvider = FutureProvider.family<AuthUser, (String, String)>((ref, credentials) async {
  final (email, password) = credentials;
  final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return AuthUser.fromFirebase(result.user!);
});

/// Register with email and password
final registerWithEmailProvider = FutureProvider.family<AuthUser, (String, String)>((ref, credentials) async {
  final (email, password) = credentials;
  final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  return AuthUser.fromFirebase(result.user!);
});

/// Sign out
final signOutProvider = FutureProvider<void>((ref) async {
  await FirebaseAuth.instance.signOut();
});
