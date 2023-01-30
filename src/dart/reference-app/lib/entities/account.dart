import 'package:teropong/entities/instance.dart';
import 'package:teropong/entities/user.dart';

class Account {
  AccountCredentialType credentialType;
  Instance instance;
  String? password, token, username;
  User? user;

  Account(
    this.instance, {
    this.credentialType = AccountCredentialType.anonymous,
    this.password,
    this.token,
    this.username,
  }) {
    // assert();
  }
}

enum AccountCredentialType {
  anonymous,
  apiToken,
  basic,
  oAuthToken,
}
