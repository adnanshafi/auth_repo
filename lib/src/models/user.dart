import 'dart:html';

import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    this.uid = 'unavailable',
    this.username,
    this.email,
    this.phone,
  });

  /// [uid] The firebase uid of the user
  final String uid;

  /// [username] : username of the user if available
  final String? username;

  /// [email] : the email address used to sign up if available
  final String? email;

  /// [phone] : the phone number of the user if phoneauth was used
  final String? phone;

  AppUser copyWith({
    String? uid,
    String Function()? username,
    String Function()? email,
    String Function()? phone,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      username: username != null ? username() : this.username,
      email: email != null ? email() : this.email,
      phone: phone != null ? phone() : this.phone,
    );
  }

  @override
  List<Object?> get props => [uid, username, email, phone];
}
