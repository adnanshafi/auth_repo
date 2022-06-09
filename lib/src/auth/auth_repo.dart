import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:auth_repo/auth_repo.dart';
import 'package:mem_cache/mem_cache.dart';

/// {@template auth_repo}
/// Repository to handle all authentication operations for firebase
///
/// [auth] : single firebase auth instance to be used
///
/// {@endtemplate}

class AuthRepo {
  /// {@macro auth_repo}
  AuthRepo({
    required firebase_auth.FirebaseAuth auth,
    required MemCache cache,
  })  : _auth = auth,
        _cache = cache;

  final firebase_auth.FirebaseAuth _auth;
  final MemCache _cache;

  static const _userCacheKey = '__user_key__';

  Stream<AppUser> get user {
    return _auth.authStateChanges().map(
      (firebaseUser) {
        final user =
            firebaseUser == null ? AppUser.empty : firebaseUser.toAppUser;
        _cache.put<AppUser>(key: _userCacheKey, value: user);
        return user;
      },
    );
  }

  AppUser get currentUser {
    return _cache.get<AppUser>(key: _userCacheKey) ?? AppUser.empty;
  }

  /// Sign up with Email & Password in Firebase & log in
  ///
  /// `email` : email to signUp with
  /// `password` : password to sign up with
  /// `onSuccess` : Optional Callback when create account is successful
  /// `onFailure` : Optional Callback when create account fails, takes a String argument to convey the message
  Future<void> createAccountWithEmailPassword(
    String email,
    String password, {
    Function(String? uid)? onSuccess,
    Function(String message)? onFailure,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.credential != null) {
        _auth.signInWithCredential(userCredential.credential!);
      }
      if (onSuccess != null) {
        if (userCredential.user != null) {
          onSuccess(userCredential.user!.uid);
        } else {
          onSuccess(null);
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (onFailure != null) {
        onFailure(_messageFromCode(e.code));
      }
    } catch (e) {
      if (onFailure != null) {
        onFailure('Please try again');
      }
    }
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
  Future<void> signInWithEmailPassword(
    String email,
    String password, {
    Function? onSuccess,
    Function(String message)? onFailure,
  }) async {
    try {
      _auth.signInWithEmailAndPassword(email: email, password: password);
      if (onSuccess != null) onSuccess();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (onFailure != null) {
        onFailure(_messageFromCode(e.code));
      }
    } catch (e) {
      if (onFailure != null) {
        onFailure('Please try again');
      }
    }
  }

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
    Function? onAutoVerify,
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
    } on firebase_auth.FirebaseAuthException catch (e) {
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
    required Function(firebase_auth.ConfirmationResult confirmationResult)
        onCodeSent,
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
    Function? onSuccess,
    Function(String message)? onFailure,
  }) async {
    firebase_auth.PhoneAuthCredential credential =
        firebase_auth.PhoneAuthProvider.credential(
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

extension on firebase_auth.User {
  AppUser get toAppUser {
    return AppUser(uid: uid);
  }
}
