library teropong;

import 'package:teropong/teropong.dart';

/// [InstanceMayAllowSignIn]s are [BaseInstance]s which uses a [BaseService]
/// which could perform user account sign ins. A [BaseInstance] implementing
/// this interface does NOT always mean that the given [BaseService] is able to
/// do so. Make sure that you have checked the support first by calling
/// [checkForSignInSupport] before calling other methods.
mixin InstanceMayAllowSignIn<T extends BaseService> on BaseInstance<T> {
  /// Check whether the instance's service supports account signins
  Future<Set<BaseSignInMethod>> checkForSignInSupport() async {
    return {};
  }

  /// Sign up with a [username], [password], and optionally [captcha], [email],
  /// [inviteCode], [phoneNumber], [reason], and others as defined in [extras]
  Future<BaseRegistrationStatus<T>?> signIn({
    String? accessToken,
    String? captcha,
    String? email,
    Map<String, dynamic>? extras,
    String? password,
    String? phoneNumber,
    String? reason,
    String? username,
  }) async {
    return null;
  }
}
