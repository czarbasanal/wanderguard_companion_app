enum AccountType { primaryCompanion, backupCompanion, patient }

extension AccountTypeExtension on AccountType {
  String get name {
    switch (this) {
      case AccountType.primaryCompanion:
        return 'primary_companion';
      case AccountType.backupCompanion:
        return 'backup_companion';
      case AccountType.patient:
        return 'patient';
    }
  }

  static AccountType fromString(String name) {
    switch (name) {
      case 'primary_companion':
        return AccountType.primaryCompanion;
      case 'backup_companion':
        return AccountType.backupCompanion;
      case 'patient':
        return AccountType.patient;
      default:
        throw ArgumentError('Invalid account type: $name');
    }
  }
}
