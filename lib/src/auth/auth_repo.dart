import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';

/// {@template auth_repo}
/// Repository to handle all authentication operations for firebase
///
/// [auth] : single firebase auth instance to be used
///
/// {@endtemplate}

class AuthRepo {
  /// {@macro auth_repo}
  AuthRepo({required FirebaseAuth auth}) : _auth = auth;

  final FirebaseAuth _auth;

  /// Sign up with Email & Password in Firebase
  ///
  /// `email` : email to signUp with
  /// `password` : password to sign up with
  /// `onSuccess` : Optional Callback when create account is successful
  /// `onFailure` : Optional Callback when create account fails, takes a String argument to convey the message
  Future<void> createAccountWithEmailPassword(
    String email,
    String password, {
    VoidCallback? onSuccess,
    Function(String message)? onFailure,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    _auth.signInWithCredential(userCredential.credential!);
  }

  /// Sign In With email & password
  ///
  /// `email` :  user email
  ///
  /// `password` : user password
  ///
  /// `onSuccess` : Optional Callback on sign in success
  ///
  /// `onFailure` : Optional Callback on sign in failure, takes a `message` argument
  Future<void> signInEmailPassword(
    String email,
    String password, {
    VoidCallback? onSuccess,
    Function(String message)? onFailure,
  }) async {}

  /// Sign in with firebase phoneauth
  ///
  /// `phoneNumber` : phone number to sign in with
  ///
  /// `onCodeSent`: called when code is sent to the device! passes a `verificationId` to caller
  ///
  /// `onVerificationFailure` : called when sending Otp to device failes! passes a  String `message` to caller
  ///
  /// `onAutoVerify` : called when SMS is auto verified
  ///
  /// `onAutoVerifyTimeout` : called when AutoVerify timeouts
  Future<void> signInWithPhoneNumber(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(String message) onVerificationFailure,
    VoidCallback? onAutoVerify,
    required Function(String verificationId) onAutoVerifyTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) {
          if (onAutoVerify != null) {
            onAutoVerify();
          }
        },
        verificationFailed: (firebaseAuthException) {
          throw firebaseAuthException;
        },
        codeSent: (verificationId, resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          onAutoVerifyTimeout(verificationId);
        },
      );
    } on FirebaseAuthException catch (e) {
      String message = _messageFromCode(e.code);
      onVerificationFailure(message);
    } catch (e) {
      onVerificationFailure('An Unknown Error Occurred');
    }
  }

  /// Sign in with firebase phoneauth for web platform only
  ///
  /// `phoneNumber` : phone number to sign in with
  ///
  /// `onCodeSent`: called when code is sent to the device! passes a `verificationId` to caller
  ///
  /// `onVerificationFailure` : called when sending Otp to device failes! passes a  String `message` to caller
  Future<void> signInWithPhoneNumberWeb(
    String phoneNumber, {
    required Function(ConfirmationResult confirmationResult) onCodeSent,
    required Function(String message) onVerificationFailure,
  }) async {}

  /// Verify Phone SMS Code for all platforms
  ///
  /// `code` : The SMS code entered by the user
  ///
  /// `verificationID` : The verification ID sent To device
  ///
  /// `onSuccess` : Optionally called when sign in success
  ///
  /// `onFailure` : Called when sign in is failure
  Future<void> verifyCode(
    String code,
    String verificationId, {
    VoidCallback? onSuccess,
    Function(String message)? onFailure,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: code);
    await _auth.signInWithCredential(credential);
  }

  /// Common method to logout on all sign in methods
  Future<void> logout() async {
    _auth.signOut();
  }

  /// User Readable Message from Error Code
  String _messageFromCode(String code) {
    return 'messageFromCodeNotImplementedYet';
  }
}
