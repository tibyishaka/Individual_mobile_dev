import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Profile Section ──
          _ProfileCard(theme: theme),
          const SizedBox(height: 16),

          // ── Appearance Section ──
          _SectionHeader(title: 'Appearance', theme: theme),
          _ThemeTile(settings: settings, theme: theme),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Language Section ──
          _SectionHeader(title: 'Language', theme: theme),
          _LanguageTile(settings: settings, theme: theme),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Location Section ──
          _SectionHeader(title: 'Location', theme: theme),
          SwitchListTile(
            secondary: Icon(
              Icons.my_location,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Use Current Location'),
            subtitle: const Text('Allow the app to access device location'),
            value: settings.useLocation,
            onChanged: (value) => settings.setUseLocation(value),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── Account Section ──
          _SectionHeader(title: 'Account', theme: theme),
          _SettingsTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'johndoe@example.com',
            theme: theme,
          ),
          _SettingsTile(
            icon: Icons.phone_outlined,
            title: 'Phone',
            subtitle: '+250 788 123 456',
            theme: theme,
          ),
          _SettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Address',
            subtitle: 'Kigali, Rwanda',
            theme: theme,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // ── More Section ──
          _SectionHeader(title: 'More', theme: theme),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            theme: theme,
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Privacy',
            theme: theme,
          ),
          const SizedBox(height: 24),

          // ── Logout Button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                'JD',
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
                    'John Doe',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'johndoe@example.com',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () {
                _showEditProfileSheet(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              Text('Edit Profile', style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 44,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Text(
                      'JD',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone',
                  hintText: '+250 788 123 456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Kigali, Rwanda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 8),
            ],
          ),
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
    final labels = {
      ThemeMode.system: 'System',
      ThemeMode.light: 'Light',
      ThemeMode.dark: 'Dark',
    };

    return ListTile(
      leading: Icon(
        _iconForMode(settings.themeMode),
        color: theme.colorScheme.primary,
      ),
      title: const Text('Theme'),
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
          Text('Choose Theme', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _themeOption(context, ThemeMode.light, Icons.light_mode, 'Light'),
          _themeOption(context, ThemeMode.dark, Icons.dark_mode, 'Dark'),
          _themeOption(
            context,
            ThemeMode.system,
            Icons.brightness_auto,
            'System Default',
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
    return ListTile(
      leading: Icon(Icons.language, color: theme.colorScheme.primary),
      title: const Text('Language'),
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
          Text('Choose Language', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ...languages.map((lang) {
            final isSelected =
                settings.locale.languageCode == lang.locale.languageCode;
            return ListTile(
              leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
              title: Text(lang.name),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: isSelected,
              selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(
                60,
              ),
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
