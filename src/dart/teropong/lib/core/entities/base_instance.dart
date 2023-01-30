library teropong;

import 'package:teropong/teropong.dart';

abstract class BaseInstance<T extends BaseService> {
  /// The URL pointing to site's About page
  final Uri? aboutUrl;

  /// The site's base API URL
  late final Uri apiUrl;

  /// The site's base URL, viewable by common users
  final Uri baseUrl;

  /// The site's official Community Guidelines URL
  final Uri? communityGuidelinesUrl;

  /// The URL pointing to the site's official logo
  final Uri? freeFormLogoUrl;

  /// The URL pointing to the site's official Privacy Policy
  final Uri? privacyPolicyUrl;

  /// The URL pointing to the site's official Help, Support, or Contact information
  final Uri? supportUrl;

  /// The URL pointing to the site's official logo, optimized for square or circular cutout
  final Uri? squareLogoUrl;

  /// The URL pointing to the site's official Terms of Service
  final Uri? termsOfServiceUrl;

  /// The BaseService object
  final T service;

  BaseInstance(
    this.service,
    this.baseUrl, {
    this.aboutUrl,
    Uri? apiUrl,
    this.communityGuidelinesUrl,
    this.freeFormLogoUrl,
    this.privacyPolicyUrl,
    this.squareLogoUrl,
    this.supportUrl,
    this.termsOfServiceUrl,
  }) {
    this.apiUrl = apiUrl ?? baseUrl;
    service.registerApiUrl(this.apiUrl);
  }
}
