library teropong;

import 'package:teropong/teropong.dart';

/// [InstanceMayHavePublicStatistics]s are [BaseInstance]s which uses a
/// [BaseService] which could get an information of the instance's public
/// statistics (e.g. number of users). A [BaseInstance] implementing this
/// interface does NOT always mean that the given [BaseService] is able to get
/// the statistical information. Make sure that you have checked the support
/// first by calling [checkForPublicStatisticSupport] before calling
/// [getPublicStatistics].
mixin InstanceMayHavePublicStatistics<T extends BaseService>
    on BaseInstance<T> {
  Future<bool> checkForPublicStatisticSupport() async {
    return false;
  }

  Future<BaseInstanceStatistics?> getPublicStatistics() async {
    return null;
  }
}
