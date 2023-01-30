enum BaseSignUpStatus {
  /// The instance is publicly opening new account registration
  open,

  /// The instance is currently closing any new account registration
  closed,

  /// The instance is currently only accepting signups under invites
  /// (e.g. Misskey)
  invite,

  /// The instance is publicly opening new account registration, but they have
  /// to be reviewed first by the instance owner (e.g. Mastodon)
  reviewed,

  /// Teropong is unable to check for account registration status due to server
  /// errors
  error,

  /// Teropong is unable to check for account registration status for other
  /// reasons
  unknown,
}
