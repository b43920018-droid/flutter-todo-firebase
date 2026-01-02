import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../constants/firestore_constants.dart';
import '../models/user_model.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
}

class AuthProvider extends ChangeNotifier {
  final auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;
  Status get status => _status;

  UserModel? get currentUser {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    final userId = prefs.getString(FirestoreConstants.id) ?? '';
    if (userId.isEmpty) return null;

    return UserModel(
      id: user.uid,
      name: prefs.getString(FirestoreConstants.name) ?? '',
      email: prefs.getString(FirestoreConstants.email) ?? '',
      password: '',
    );
  }

  AuthProvider({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.prefs,
  });

  String? getUserFirebaseId() => prefs.getString(FirestoreConstants.id);

  Future<bool> isLoggedIn() async {
    return firebaseAuth.currentUser != null &&
        prefs.getString(FirestoreConstants.id)?.isNotEmpty == true;
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      final auth.UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final auth.User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _status = Status.authenticateError;
        notifyListeners();
        debugPrint("Firebase user is null after login.");
        return false;
      }

      final userDoc = await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(firebaseUser.uid)
          .get();
      if (!userDoc.exists) {
        _status = Status.authenticateError;
        notifyListeners();
        debugPrint("User document does not exist in Firestore.");
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final storedHash = userData[FirestoreConstants.password] as String?;
      if (storedHash == null || !comparePasswords(password, storedHash)) {
        _status = Status.authenticateError;
        notifyListeners();
        debugPrint("Password mismatch or hash not found.");
        return false;
      }

      final user = UserModel.fromDocument(userDoc);
      await prefs.setString(FirestoreConstants.id, user.id);
      await prefs.setString(FirestoreConstants.name, user.name);
      await prefs.setString(FirestoreConstants.email, user.email);

      _status = Status.authenticated;
      notifyListeners();
      debugPrint("Login successful, user: ${user.email}");
      return true;
    } on auth.FirebaseAuthException catch (e) {
      _status = Status.authenticateException;
      notifyListeners();
      debugPrint("Login error: ${e.message}");
      return false;
    } catch (e) {
      _status = Status.authenticateException;
      notifyListeners();
      debugPrint("Login exception: $e");
      return false;
    }
  }

  Future<String?> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      if (password != confirmPassword) {
        return "Passwords do not match.";
      }

      final auth.UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        _status = Status.authenticateError;
        notifyListeners();
        return "An error occurred while creating the account. Please try again later.";
      }

      final hashedPassword = hashPassword(password);
      final newUser = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
        password: hashedPassword,
      );

      await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(firebaseUser.uid)
          .set(newUser.toJson());

      await prefs.setString(FirestoreConstants.id, firebaseUser.uid);
      await prefs.setString(FirestoreConstants.name, name);
      await prefs.setString(FirestoreConstants.email, email);

      _status = Status.authenticated;
      notifyListeners();
      return null;
    } on auth.FirebaseAuthException catch (e) {
      _status = Status.authenticateException;
      notifyListeners();
      debugPrint("Registration error: ${e.message}");
      return e.message;
    } catch (e) {
      _status = Status.authenticateException;
      notifyListeners();
      debugPrint("Registration error: $e");
      return "An unexpected error occurred during registration.";
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      _status = Status.authenticating;
      notifyListeners();

      await firebaseAuth.sendPasswordResetEmail(email: email);
      _status = Status.authenticated;
      notifyListeners();
      return null;
    } on auth.FirebaseAuthException catch (e) {
      _status = Status.authenticateException;
      notifyListeners();
      debugPrint("Reset password error: ${e.message}");
      return e.message;
    } catch (e) {
      _status = Status.authenticateException;
      notifyListeners();
      debugPrint("Reset password error: $e");
      return "An unexpected error occurred during password reset.";
    }
  }

  Future<String?> updateProfile({
    required String name,
    String? email,
    String? password,
    BuildContext? context,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return "User not logged in";

      if (email != null && email.isNotEmpty && email != user.email) {
        try {
          String currentPassword = await _promptForCurrentPassword(context);
          if (currentPassword.isEmpty) {
            return "Current password is required to update email.";
          }

          await user.reauthenticateWithCredential(
            auth.EmailAuthProvider.credential(
              email: user.email!,
              password: currentPassword,
            ),
          );

          await user.verifyBeforeUpdateEmail(email);
          return "Verification email sent. Please check your new email to complete the update.";
        } catch (e) {
          debugPrint("Email update error: $e");
          return "Failed to update email. Please ensure the current password is correct.";
        }
      }

      if (password != null && password.isNotEmpty) {
        final hashedPassword = hashPassword(password);
        await user.updatePassword(password);
        await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(user.uid)
            .update({FirestoreConstants.password: hashedPassword});
      }

      final updates = <String, dynamic>{};
      if (name.isNotEmpty) {
        updates[FirestoreConstants.name] = name;
      }
      if (email != null && email.isNotEmpty) {
        updates[FirestoreConstants.email] = email;
      }

      if (updates.isNotEmpty) {
        await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(user.uid)
            .update(updates);
      }

      if (name.isNotEmpty) {
        await prefs.setString(FirestoreConstants.name, name);
      }
      if (email != null && email.isNotEmpty) {
        await prefs.setString(FirestoreConstants.email, email);
      }

      notifyListeners();
      return null;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint("Update error: ${e.message}");
      return e.message ?? "An error occurred";
    } catch (e) {
      debugPrint("Update exception: $e");
      return "An unexpected error occurred";
    }
  }

  Future<String> _promptForCurrentPassword(BuildContext? context) async {
    if (context == null) return '';
    String currentPassword = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Current Password'),
        content: TextField(
          obscureText: true,
          onChanged: (value) => currentPassword = value,
          decoration: const InputDecoration(hintText: 'Current Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (currentPassword.isNotEmpty) {
                Navigator.pop(context, currentPassword);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    return currentPassword;
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    notifyListeners();
    await firebaseAuth.signOut();
    await prefs.clear();
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool comparePasswords(String inputPassword, String storedHash) {
    var inputHash = hashPassword(inputPassword);
    return inputHash == storedHash;
  }
}
