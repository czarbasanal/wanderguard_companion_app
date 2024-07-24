enum AccountStatus { online, offline }

extension AccountStatusExtension on AccountStatus {
  String get name {
    switch (this) {
      case AccountStatus.offline:
        return 'offline';
      case AccountStatus.online:
        return 'online';
    }
  }

  static AccountStatus fromString(String name) {
    switch (name) {
      case 'offline':
        return AccountStatus.offline;
      case 'online':
        return AccountStatus.online;
      default:
        throw ArgumentError('Invalid account status: $name');
    }
  }
}
