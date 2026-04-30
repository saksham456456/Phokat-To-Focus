import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isAuthenticated = false;
  bool _isPremium = false;
  String? _userName;
  String? _uid;

  AuthProvider() {
    try {
      _firebaseAuth = FirebaseAuth.instance;
    } catch (_) {
      debugPrint("Firebase not initialized yet. Using local auth.");
    }
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Check Firebase Auth state first
    final currentUser = _firebaseAuth?.currentUser;
    if (currentUser != null) {
      _isAuthenticated = true;
      _uid = currentUser.uid;
      _userName = currentUser.displayName ?? currentUser.email?.split('@').first;
      _isPremium = prefs.getBool('auth_is_premium_$_uid') ?? false;
    } else {
      _isAuthenticated = false;
      _uid = null;
      _isPremium = false;
    }

    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_uid != null) {
      await prefs.setBool('auth_is_premium_$_uid', _isPremium);
      if (_userName != null) {
        await prefs.setString('auth_user_name_$_uid', _userName!);
      }
    }
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isPremium => _isPremium;
  String? get userName => _userName;
  String? get uid => _uid;

  // Firebase Real Login
  Future<void> login(String email, String password) async {
    if (_firebaseAuth == null) {
      // Fallback for Demo/Offline Mode
      debugPrint("Firebase not found. Logging in locally for demo.");
      _isAuthenticated = true;
      _uid = "local_user";
      _userName = email.split('@').first;
      await _saveState();
      notifyListeners();
      return;
    }

    try {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _uid = credential.user?.uid;
      _userName = credential.user?.displayName ?? email.split('@').first;
      await _saveState();
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    if (_firebaseAuth == null) {
      // Fallback for Demo
      _isAuthenticated = true;
      _uid = "local_google_user";
      _userName = "Guest User";
      await _saveState();
      notifyListeners();
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return; // User canceled the sign-in flow
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth!.signInWithCredential(credential);

      _isAuthenticated = true;
      _uid = userCredential.user?.uid;
      _userName = userCredential.user?.displayName ?? googleUser.email.split('@').first;
      await _saveState();
      notifyListeners();
    } catch (e) {
      throw Exception('Google Sign-In Failed: ${e.toString()}');
    }
  }

  Future<void> signup(String email, String password, String name) async {
    if (_firebaseAuth == null) {
      // Fallback for Demo
      _isAuthenticated = true;
      _uid = "local_user";
      _userName = name;
      _isPremium = false;
      await _saveState();
      notifyListeners();
      return;
    }

    try {
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      _isAuthenticated = true;
      _uid = credential.user?.uid;
      _userName = name;
      _isPremium = false;
      await _saveState();
      notifyListeners();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void logout() async {
    try {
      await _firebaseAuth?.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}

    _isAuthenticated = false;
    _userName = null;
    _uid = null;
    _isPremium = false;
    notifyListeners();
  }

  void upgradeToPremium() async {
    _isPremium = true;
    await _saveState();
    notifyListeners();
  }
}
