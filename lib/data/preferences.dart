/// Theme choice on the Profile page (Figma "Theme" sheet).
enum ThemePreference {
  system('Match system', 'Follows your phone’s setting'),
  light('Light', 'Cream background, always'),
  dark('Dark', 'Easier on the eyes at night');

  const ThemePreference(this.label, this.description);
  final String label;
  final String description;
}

/// App language (Figma "Language" EN / DE).
enum AppLanguage {
  en('EN'),
  de('DE');

  const AppLanguage(this.code);
  final String code;
}

/// Push notification switches (Figma "Notification" settings).
class NotificationPrefs {
  const NotificationPrefs({
    this.partnerAdds = true,
    this.partnerCompletes = true,
    this.invitations = true,
  });

  final bool partnerAdds;
  final bool partnerCompletes;
  final bool invitations;

  int get enabledCount =>
      [partnerAdds, partnerCompletes, invitations].where((on) => on).length;

  NotificationPrefs copyWith({
    bool? partnerAdds,
    bool? partnerCompletes,
    bool? invitations,
  }) =>
      NotificationPrefs(
        partnerAdds: partnerAdds ?? this.partnerAdds,
        partnerCompletes: partnerCompletes ?? this.partnerCompletes,
        invitations: invitations ?? this.invitations,
      );
}

/// Pro billing period, shown as "Pro · yearly".
enum ProBilling { yearly, monthly }
