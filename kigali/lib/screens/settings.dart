import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/listings_provider.dart';
import '../providers/settings_provider.dart';
import 'sign_in.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(l10n?.settingsTitle ?? 'Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Profile Section ──
          _ProfileCard(theme: theme),
          const SizedBox(height: 16),

          // ── Appearance Section ──
          _SectionHeader(title: l10n?.appearance ?? 'Appearance', theme: theme),
          _ThemeTile(settings: settings, theme: theme),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Notifications Section ──
          _SectionHeader(
              title: l10n?.notifications ?? 'Notifications', theme: theme),
          SwitchListTile(
            secondary: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n?.notifications ?? 'Notifications'),
            subtitle:
                Text(l10n?.notificationsDesc ?? 'Enable push notifications'),
            value: settings.notificationsEnabled,
            onChanged: (value) => settings.setNotificationsEnabled(value),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Language Section ──
          _SectionHeader(title: l10n?.language ?? 'Language', theme: theme),
          _LanguageTile(settings: settings, theme: theme),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Location Section ──
          _SectionHeader(title: l10n?.location ?? 'Location', theme: theme),
          SwitchListTile(
            secondary: Icon(
              Icons.my_location,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n?.useCurrentLocation ?? 'Use Current Location'),
            subtitle: Text(
                l10n?.useLocationDesc ??
                    'Allow the app to access device location'),
            value: settings.useLocation,
            onChanged: (value) => settings.setUseLocation(value),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.notifications_active_outlined,
              color: settings.useLocation
                  ? theme.colorScheme.primary
                  : theme.disabledColor,
            ),
            title:
                Text(l10n?.locationNotifs ?? 'Location Notifications'),
            subtitle: Text(
              l10n?.locationNotifsDesc ??
                  'Receive notifications based on your location',
            ),
            value: settings.locationNotifications,
            onChanged: settings.useLocation && settings.notificationsEnabled
                ? (value) => settings.setLocationNotifications(value)
                : null,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Account Section ──
          _SectionHeader(
              title: l10n?.account ?? 'Account', theme: theme),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (_, snap) {
              final email = snap.data?.email ?? '';
              return ListTile(
                leading: Icon(
                  Icons.email_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l10n?.email ?? 'Email'),
                subtitle: Text(
                  email.isNotEmpty ? email : '—',
                  style: theme.textTheme.bodySmall,
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── More Section ──
          _SectionHeader(title: l10n?.more ?? 'More', theme: theme),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n?.about ?? 'About',
            subtitle: l10n?.version ?? 'Version 1.0.0',
            theme: theme,
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: l10n?.termsPrivacy ?? 'Terms & Privacy',
            theme: theme,
          ),
          const SizedBox(height: 24),

          // ── Logout Button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n?.logOut ?? 'Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Profile Card
// ──────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final ThemeData theme;
  const _ProfileCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final provider = ListingsScope.of(context);
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snap) {
        final user = snap.data;
        final displayName = user?.displayName ?? '';
        final email = user?.email ?? '';
        final initials = displayName.trim().isNotEmpty
            ? displayName
                  .trim()
                  .split(' ')
                  .where((w) => w.isNotEmpty)
                  .take(2)
                  .map((w) => w[0].toUpperCase())
                  .join()
            : (email.isNotEmpty ? email[0].toUpperCase() : '?');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    initials,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isNotEmpty
                            ? displayName
                            : (AppLocalizations.of(context)?.noNameSet ??
                                'No name set'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email.isNotEmpty ? email : '—',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () =>
                      _showEditProfileSheet(context, provider, displayName),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                      AppLocalizations.of(context)?.edit ?? 'Edit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileSheet(
    BuildContext context,
    ListingsProvider provider,
    String currentName,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: currentName);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n?.editProfile ?? 'Edit Profile',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n?.displayName ?? 'Display Name',
                      hintText: l10n?.yourFullName ?? 'Your full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;
                            setModalState(() => isSaving = true);
                            try {
                              await provider.saveDisplayName(name);
                              if (context.mounted) Navigator.pop(context);
                            } finally {
                              if (context.mounted) {
                                setModalState(() => isSaving = false);
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n?.saveChanges ?? 'Save Changes'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
//  Section Header
// ──────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Theme Tile
// ──────────────────────────────────────────────
class _ThemeTile extends StatelessWidget {
  final SettingsProvider settings;
  final ThemeData theme;
  const _ThemeTile({required this.settings, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      ThemeMode.system: l10n?.themeSystem ?? 'System',
      ThemeMode.light: l10n?.themeLight ?? 'Light',
      ThemeMode.dark: l10n?.themeDark ?? 'Dark',
    };

    return ListTile(
      leading: Icon(
        _iconForMode(settings.themeMode),
        color: theme.colorScheme.primary,
      ),
      title: Text(l10n?.theme ?? 'Theme'),
      subtitle: Text(labels[settings.themeMode]!),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _ThemePickerSheet(settings: settings),
        );
      },
    );
  }

  IconData _iconForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

class _ThemePickerSheet extends StatelessWidget {
  final SettingsProvider settings;
  const _ThemePickerSheet({required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n?.chooseTheme ?? 'Choose Theme',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _themeOption(context, ThemeMode.light, Icons.light_mode,
              l10n?.themeLight ?? 'Light'),
          _themeOption(context, ThemeMode.dark, Icons.dark_mode,
              l10n?.themeDark ?? 'Dark'),
          _themeOption(
            context,
            ThemeMode.system,
            Icons.brightness_auto,
            l10n?.themeSystemDefault ?? 'System Default',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = settings.themeMode == mode;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(60),
      onTap: () {
        settings.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }
}

// ──────────────────────────────────────────────
//  Language Tile
// ──────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final SettingsProvider settings;
  final ThemeData theme;
  const _LanguageTile({required this.settings, required this.theme});

  static const _languages = [
    _LangOption('English', Locale('en'), '🇬🇧'),
    _LangOption('Français', Locale('fr'), '🇫🇷'),
    _LangOption('Kinyarwanda', Locale('rw'), '🇷🇼'),
    _LangOption('Kiswahili', Locale('sw'), '🇹🇿'),
    _LangOption('Deutsch', Locale('de'), '🇩🇪'),
    _LangOption('Español', Locale('es'), '🇪🇸'),
  ];

  String _currentLanguageName() {
    return _languages
        .firstWhere(
          (l) => l.locale.languageCode == settings.locale.languageCode,
          orElse: () => _languages.first,
        )
        .name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(Icons.language, color: theme.colorScheme.primary),
      title: Text(l10n?.language ?? 'Language'),
      subtitle: Text(_currentLanguageName()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) =>
              _LanguagePickerSheet(settings: settings, languages: _languages),
        );
      },
    );
  }
}

class _LangOption {
  final String name;
  final Locale locale;
  final String flag;
  const _LangOption(this.name, this.locale, this.flag);
}

class _LanguagePickerSheet extends StatelessWidget {
  final SettingsProvider settings;
  final List<_LangOption> languages;
  const _LanguagePickerSheet({required this.settings, required this.languages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n?.chooseLanguage ?? 'Choose Language',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ...languages.map((lang) {
            final isSelected =
                settings.locale.languageCode == lang.locale.languageCode;
            return ListTile(
              leading:
                  Text(lang.flag, style: const TextStyle(fontSize: 24)),
              title: Text(lang.name),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: isSelected,
              selectedTileColor:
                  theme.colorScheme.primaryContainer.withAlpha(60),
              onTap: () {
                settings.setLocale(lang.locale);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Generic Settings Tile (static info rows)
// ──────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final ThemeData theme;
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
    );
  }
}
