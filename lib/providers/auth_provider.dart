import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The three high-level “connection” states our UI cares about.
enum AuthState { loading, authenticated, unauthenticated }

/// A very thin wrapper around FirebaseAuth that notifies listeners
/// any time the current user changes.
class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;

  AuthState _state = AuthState.loading;
  AuthState get state => _state;

  User? get user => _auth.currentUser; // convenience getter

  /// Start listening to Firebase’s authStateChanges stream as soon
  /// as the provider is created.  This fires on app launch and after
  /// every login / logout / e-mail-verification update.
  AuthProvider() {
    _auth.authStateChanges().listen(_onChange);
  }

  //  Public API used by our Login & Register screens

  Future<void> signIn(String email, String pwd) =>
      _auth.signInWithEmailAndPassword(email: email, password: pwd);

  Future<void> register(String email, String pwd) =>
      _auth.createUserWithEmailAndPassword(email: email, password: pwd);

  Future<void> signOut() => _auth.signOut();

  //  Private helpers

  void _onChange(User? _) {
    // Translate Firebase’s nullable User into our simple enum.
    _state =
        (_auth.currentUser == null)
            ? AuthState.unauthenticated
            : AuthState.authenticated;
    notifyListeners(); // wake any Consumer widgets
  }
}
