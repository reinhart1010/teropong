library teropong;

import 'package:teropong/teropong.dart';

/// [InstanceMayAllowSignUp]s are [BaseInstance]s which uses a [BaseService]
/// which could perform user account registration (aka. "sign up").
/// A [BaseInstance] implementing this interface does NOT always mean that the
/// given [BaseService] is able to do so. Make sure that you have checked the
/// support first by calling [checkForSignUpSupport] before calling other
/// methods.
mixin InstanceMayAllowSignUp<T extends BaseService> on BaseInstance<T> {
  /// Check whether the instance's service supports account signups
  Future<BaseSignUpStatus> checkForSignUpSupport() async {
    return BaseSignUpStatus.unknown;
  }

  /// Sign up with a [username], [password], and optionally [captcha], [email],
  /// [inviteCode], [phoneNumber], [reason], and others as defined in [extras]
  Future<BaseRegistrationStatus<T>?> signUp(
    String username,
    String password, {
    String? captcha,
    String? email,
    String? inviteCode,
    Map<String, dynamic>? extras,
    String? phoneNumber,
    String? reason,
  }) async {
    return null;
  }
}
