import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Simple map-based localization — no code generation required.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('rw'),
    Locale('sw'),
    Locale('de'),
    Locale('es'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  String _t(String key) =>
      _strings[locale.languageCode]?[key] ?? _strings['en']![key] ?? key;

  // ── Navigation ──
  String get navHome => _t('navHome');
  String get navMap => _t('navMap');
  String get navListings => _t('navListings');
  String get navSettings => _t('navSettings');

  // ── Home ──
  String get homeWelcome => _t('homeWelcome');
  String get homeDiscover => _t('homeDiscover');

  // ── Category buttons ──
  String get catHealth => _t('catHealth');
  String get catGovernment => _t('catGovernment');
  String get catEntertainment => _t('catEntertainment');
  String get catEducation => _t('catEducation');
  String get catTourist => _t('catTourist');

  /// Returns the localized display name for an English category key.
  String categoryLabel(String key) {
    const map = {
      'Health': 'catHealth',
      'Government': 'catGovernment',
      'Entertainment': 'catEntertainment',
      'Education': 'catEducation',
      'Tourist Attraction': 'catTourist',
    };
    return _t(map[key] ?? key);
  }

  // ── Category screen ──
  String get searchHint => _t('searchHint');
  String get noListings => _t('noListings');

  // ── Settings ──
  String get settingsTitle => _t('settingsTitle');
  String get appearance => _t('appearance');
  String get theme => _t('theme');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get themeSystem => _t('themeSystem');
  String get chooseTheme => _t('chooseTheme');
  String get themeSystemDefault => _t('themeSystemDefault');
  String get notifications => _t('notifications');
  String get notificationsDesc => _t('notificationsDesc');
  String get language => _t('language');
  String get chooseLanguage => _t('chooseLanguage');
  String get location => _t('location');
  String get useCurrentLocation => _t('useCurrentLocation');
  String get useLocationDesc => _t('useLocationDesc');
  String get locationNotifs => _t('locationNotifs');
  String get locationNotifsDesc => _t('locationNotifsDesc');
  String get account => _t('account');
  String get email => _t('email');
  String get more => _t('more');
  String get about => _t('about');
  String get version => _t('version');
  String get termsPrivacy => _t('termsPrivacy');
  String get logOut => _t('logOut');
  String get edit => _t('edit');
  String get editProfile => _t('editProfile');
  String get displayName => _t('displayName');
  String get yourFullName => _t('yourFullName');
  String get saveChanges => _t('saveChanges');
  String get noNameSet => _t('noNameSet');

  // ── Map screen ──
  String get searchHintMap => _t('searchHintMap');
  String get getDirections => _t('getDirections');
  String get clearRoute => _t('clearRoute');
  String get myLocation => _t('myLocation');
  String get streetView => _t('streetView');
  String get satelliteView => _t('satelliteView');
  String get showingFilter => _t('showingFilter');
  String get directionsTitle => _t('directionsTitle');
  String get yourLocation => _t('yourLocation');
  String get gettingLocation => _t('gettingLocation');
  String get searchDestination => _t('searchDestination');
  String get noLocationWarning => _t('noLocationWarning');

  // ── Listings / Directory screen ──
  String get listingsTitle => _t('listingsTitle');
  String get searchHintDirectory => _t('searchHintDirectory');
  String get filterAll => _t('filterAll');
  String get failedLoad => _t('failedLoad');
  String get retryLabel => _t('retryLabel');

  // ── Delete dialog ──
  String get deleteListingTitle => _t('deleteListingTitle');
  String deleteConfirmMsg(String name) =>
      _t('deleteConfirm').replaceAll('%s', name);
  String get cancelLabel => _t('cancelLabel');
  String get deleteLabel => _t('deleteLabel');

  // ── Subcategories ──
  String subcategoryLabel(String key) =>
      _subcategoryStrings[locale.languageCode]?[key] ??
      _subcategoryStrings['en']?[key] ??
      key;

  // ── Sign In ──
  String get cityGuide => _t('cityGuide');
  String get forgotPassword => _t('forgotPassword');
  String get signIn => _t('signIn');
  String get noAccount => _t('noAccount');
  String get register => _t('register');
  String get password => _t('password');
  String get emailRequired => _t('emailRequired');
  String get enterValidEmail => _t('enterValidEmail');
  String get passwordRequired => _t('passwordRequired');
  String get enterEmailFirst => _t('enterEmailFirst');
  String get resetEmailSent => _t('resetEmailSent');

  // ── Register ──
  String get createAccount => _t('createAccount');
  String get joinKigali => _t('joinKigali');
  String get joinSubtitle => _t('joinSubtitle');
  String get fullName => _t('fullName');
  String get confirmPassword => _t('confirmPassword');
  String get alreadyAccount => _t('alreadyAccount');
  String get nameRequired => _t('nameRequired');
  String get min6Chars => _t('min6Chars');
  String get passwordsNoMatch => _t('passwordsNoMatch');
  String get confirmPasswordReq => _t('confirmPasswordReq');

  // ── Auth errors ──
  String signInError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        return _t('errInvalidCredential');
      case 'wrong-password':
        return _t('errWrongPassword');
      case 'invalid-email':
        return _t('errInvalidEmail');
      case 'user-disabled':
        return _t('errUserDisabled');
      case 'too-many-requests':
        return _t('errTooManyRequests');
      default:
        return _t('errSignInFailed');
    }
  }

  String registerError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return _t('errEmailInUse');
      case 'invalid-email':
        return _t('errInvalidEmail');
      case 'weak-password':
        return _t('errWeakPassword');
      case 'operation-not-allowed':
        return _t('errOpNotAllowed');
      default:
        return _t('errRegFailed');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Translation tables
  // ─────────────────────────────────────────────────────────────
  static const _strings = <String, Map<String, String>>{
    // ── English ──────────────────────────────────────────────
    'en': {
      'navHome': 'Home',
      'navMap': 'Map',
      'navListings': 'Listings',
      'navSettings': 'Settings',
      'homeWelcome': 'Welcome to Kigali',
      'homeDiscover': 'Discover Kigali',
      'catHealth': 'Health',
      'catGovernment': 'Government',
      'catEntertainment': 'Entertainment',
      'catEducation': 'Education',
      'catTourist': 'Tourist Attraction',
      'searchHint': 'Search...',
      'noListings': 'No listings found',
      'settingsTitle': 'Settings',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System',
      'chooseTheme': 'Choose Theme',
      'themeSystemDefault': 'System Default',
      'notifications': 'Notifications',
      'notificationsDesc': 'Enable push notifications',
      'language': 'Language',
      'chooseLanguage': 'Choose Language',
      'location': 'Location',
      'useCurrentLocation': 'Use Current Location',
      'useLocationDesc': 'Allow the app to access device location',
      'locationNotifs': 'Location Notifications',
      'locationNotifsDesc': 'Receive notifications based on your location',
      'account': 'Account',
      'email': 'Email',
      'more': 'More',
      'about': 'About',
      'version': 'Version 1.0.0',
      'termsPrivacy': 'Terms & Privacy',
      'logOut': 'Log Out',
      'edit': 'Edit',
      'editProfile': 'Edit Profile',
      'displayName': 'Display Name',
      'yourFullName': 'Your full name',
      'saveChanges': 'Save Changes',
      'noNameSet': 'No name set',
      'cityGuide': 'City Guide',
      'forgotPassword': 'Forgot password?',
      'signIn': 'Sign In',
      'noAccount': "Don't have an account?",
      'register': 'Register',
      'password': 'Password',
      'emailRequired': 'Email is required',
      'enterValidEmail': 'Enter a valid email',
      'passwordRequired': 'Password is required',
      'enterEmailFirst': 'Enter your email address first',
      'resetEmailSent': 'Password reset email sent!',
      'createAccount': 'Create Account',
      'joinKigali': 'Join Kigali',
      'joinSubtitle': 'Create an account to add and manage listings',
      'fullName': 'Full Name',
      'confirmPassword': 'Confirm Password',
      'alreadyAccount': 'Already have an account?',
      'nameRequired': 'Name is required',
      'min6Chars': 'At least 6 characters required',
      'passwordsNoMatch': 'Passwords do not match',
      'confirmPasswordReq': 'Please confirm your password',
      'errInvalidCredential': 'Invalid email or password.',
      'errWrongPassword': 'Incorrect password.',
      'errInvalidEmail': 'Invalid email address.',
      'errUserDisabled': 'This account has been disabled.',
      'errTooManyRequests': 'Too many attempts. Try again later.',
      'errSignInFailed': 'Sign in failed. Please try again.',
      'errEmailInUse': 'An account already exists for this email.',
      'errWeakPassword': 'Password is too weak (minimum 6 characters).',
      'errOpNotAllowed': 'Email sign-up is not enabled. Contact support.',
      'errRegFailed':
          'Registration failed. Please try again.', // ── Map screen ──
      'searchHintMap': 'Search for a place in Kigali...',
      'getDirections': 'Get Directions',
      'clearRoute': 'Clear Route',
      'myLocation': 'My Location',
      'streetView': 'Street View',
      'satelliteView': 'Satellite View',
      'showingFilter': 'Showing',
      'directionsTitle': 'Plan Your Route',
      'yourLocation': 'Your location',
      'gettingLocation': 'Getting location...',
      'searchDestination': 'Search for destination...',
      'noLocationWarning': 'Location not available. Enable location services.',
      // ── Listings / Directory screen ──
      'listingsTitle': 'Directory',
      'searchHintDirectory': 'Search by name...',
      'filterAll': 'All',
      'failedLoad': 'Failed to load listings',
      'retryLabel': 'Retry',
      'deleteListingTitle': 'Delete Listing',
      'deleteConfirm': 'Delete "%s"? This cannot be undone.',
      'cancelLabel': 'Cancel',
      'deleteLabel': 'Delete',
    },

    // ── Français ──────────────────────────────────────────────
    'fr': {
      'navHome': 'Accueil',
      'navMap': 'Carte',
      'navListings': 'Annonces',
      'navSettings': 'Paramètres',
      'homeWelcome': 'Bienvenue à Kigali',
      'homeDiscover': 'Découvrir Kigali',
      'catHealth': 'Santé',
      'catGovernment': 'Gouvernement',
      'catEntertainment': 'Divertissement',
      'catEducation': 'Éducation',
      'catTourist': 'Site touristique',
      'searchHint': 'Rechercher...',
      'noListings': 'Aucune annonce trouvée',
      'settingsTitle': 'Paramètres',
      'appearance': 'Apparence',
      'theme': 'Thème',
      'themeLight': 'Clair',
      'themeDark': 'Sombre',
      'themeSystem': 'Système',
      'chooseTheme': 'Choisir un thème',
      'themeSystemDefault': 'Système par défaut',
      'notifications': 'Notifications',
      'notificationsDesc': 'Activer les notifications push',
      'language': 'Langue',
      'chooseLanguage': 'Choisir la langue',
      'location': 'Localisation',
      'useCurrentLocation': 'Utiliser ma position',
      'useLocationDesc': "Autoriser l'accès à la position de l'appareil",
      'locationNotifs': 'Notifications de position',
      'locationNotifsDesc': 'Recevoir des notifications selon votre position',
      'account': 'Compte',
      'email': 'E-mail',
      'more': 'Plus',
      'about': 'À propos',
      'version': 'Version 1.0.0',
      'termsPrivacy': 'Conditions & Confidentialité',
      'logOut': 'Se déconnecter',
      'edit': 'Modifier',
      'editProfile': 'Modifier le profil',
      'displayName': "Nom d'affichage",
      'yourFullName': 'Votre nom complet',
      'saveChanges': 'Enregistrer',
      'noNameSet': 'Aucun nom défini',
      'cityGuide': 'Guide de la Ville',
      'forgotPassword': 'Mot de passe oublié ?',
      'signIn': 'Se connecter',
      'noAccount': "Pas encore de compte ?",
      'register': "S'inscrire",
      'password': 'Mot de passe',
      'emailRequired': "L'e-mail est requis",
      'enterValidEmail': 'Entrez un e-mail valide',
      'passwordRequired': 'Le mot de passe est requis',
      'enterEmailFirst': "Entrez d'abord votre adresse e-mail",
      'resetEmailSent': 'E-mail de réinitialisation envoyé !',
      'createAccount': 'Créer un compte',
      'joinKigali': 'Rejoindre Kigali',
      'joinSubtitle': 'Créez un compte pour ajouter et gérer des annonces',
      'fullName': 'Nom complet',
      'confirmPassword': 'Confirmer le mot de passe',
      'alreadyAccount': 'Vous avez déjà un compte ?',
      'nameRequired': 'Le nom est requis',
      'min6Chars': 'Au moins 6 caractères requis',
      'passwordsNoMatch': 'Les mots de passe ne correspondent pas',
      'confirmPasswordReq': 'Veuillez confirmer votre mot de passe',
      'errInvalidCredential': 'E-mail ou mot de passe invalide.',
      'errWrongPassword': 'Mot de passe incorrect.',
      'errInvalidEmail': 'Adresse e-mail invalide.',
      'errUserDisabled': 'Ce compte a été désactivé.',
      'errTooManyRequests': 'Trop de tentatives. Réessayez plus tard.',
      'errSignInFailed': 'Échec de connexion. Veuillez réessayer.',
      'errEmailInUse': 'Un compte existe déjà pour cet e-mail.',
      'errWeakPassword': 'Mot de passe trop faible (minimum 6 caractères).',
      'errOpNotAllowed': "L'inscription par e-mail n'est pas activée.",
      'errRegFailed':
          "Échec de l'inscription. Veuillez réessayer.", // ── Map screen ──
      'searchHintMap': 'Rechercher un lieu à Kigali...',
      'getDirections': 'Obtenir l\'itinéraire',
      'clearRoute': 'Effacer l\'itinéraire',
      'myLocation': 'Ma position',
      'streetView': 'Vue de rue',
      'satelliteView': 'Vue satellite',
      'showingFilter': 'Affichage',
      'directionsTitle': 'Planifier votre itinéraire',
      'yourLocation': 'Votre position',
      'gettingLocation': 'Localisation en cours...',
      'searchDestination': 'Rechercher une destination...',
      'noLocationWarning': 'Position indisponible. Activez la localisation.',
      // ── Listings / Directory screen ──
      'listingsTitle': 'Répertoire',
      'searchHintDirectory': 'Rechercher par nom...',
      'filterAll': 'Tout',
      'failedLoad': 'Échec du chargement des annonces',
      'retryLabel': 'Réessayer',
      'deleteListingTitle': "Supprimer l'annonce",
      'deleteConfirm': 'Supprimer "%s" ? Cette action est irréversible.',
      'cancelLabel': 'Annuler',
      'deleteLabel': 'Supprimer',
    },

    // ── Kinyarwanda ───────────────────────────────────────────
    'rw': {
      'navHome': 'Ahabanza',
      'navMap': 'Ikarita',
      'navListings': 'Urutonde',
      'navSettings': 'Igenamiterere',
      'homeWelcome': 'Murakaza neza i Kigali',
      'homeDiscover': 'Turuka Kigali',
      'catHealth': 'Ubuvuzi',
      'catGovernment': 'Leta',
      'catEntertainment': 'Imyidagaduro',
      'catEducation': 'Uburezi',
      'catTourist': 'Ubukerarugendo',
      'searchHint': 'Shakisha...',
      'noListings': 'Nta rutonde rwabonetse',
      'settingsTitle': 'Igenamiterere',
      'appearance': 'Imiterere',
      'theme': 'Icyitegererezo',
      'themeLight': 'Mwangaza',
      'themeDark': 'Umukara',
      'themeSystem': 'Sisiteme',
      'chooseTheme': 'Hitamo Icyitegererezo',
      'themeSystemDefault': 'Sisiteme ya Mbuto',
      'notifications': 'Imenyesha',
      'notificationsDesc': 'Ohereza imenyesha',
      'language': 'Ururimi',
      'chooseLanguage': 'Hitamo Ururimi',
      'location': 'Aho ureba',
      'useCurrentLocation': 'Koresha Aho Ureba Ubu',
      'useLocationDesc': 'Uruhusa rwa gukoresha aho ureba',
      'locationNotifs': "Imenyesha y'Ahantu",
      'locationNotifsDesc': 'Akira imenyesha ikurikiye aho ureba',
      'account': 'Konti',
      'email': 'Imeyili',
      'more': 'Ibindi',
      'about': 'Ibyerekeye',
      'version': 'Verisiyo 1.0.0',
      'termsPrivacy': "Amategeko n'Ibanga",
      'logOut': 'Sohoka',
      'edit': 'Hindura',
      'editProfile': 'Hindura Umwirondoro',
      'displayName': 'Izina ryerekana',
      'yourFullName': 'Amazina yawe yuzuye',
      'saveChanges': 'Bika Impinduka',
      'noNameSet': 'Nta zina ryashyizweho',
      'cityGuide': "Ubuyobozi bw'Umujyi",
      'forgotPassword': 'Wibagiwe ijambo banga?',
      'signIn': 'Injira',
      'noAccount': 'Nta konti ufite?',
      'register': 'Iyandikishe',
      'password': 'Ijambo banga',
      'emailRequired': 'Imeyili irakenewe',
      'enterValidEmail': 'Injiza imeyili yemewe',
      'passwordRequired': 'Ijambo banga rirakenewe',
      'enterEmailFirst': 'Banza injiza imeyili yawe',
      'resetEmailSent': 'Imeyili yo guhindura ijambo banga yoherejwe!',
      'createAccount': 'Fungura Konti',
      'joinKigali': 'Injira muri Kigali',
      'joinSubtitle':
          'Fungura konti kugira ngo wongeremo kandi ugenzure urutonde',
      'fullName': 'Amazina Yuzuye',
      'confirmPassword': 'Emeza Ijambo banga',
      'alreadyAccount': 'Usanze ufite konti?',
      'nameRequired': 'Izina rirakenewe',
      'min6Chars': 'Nibura inyuguti 6 zirakenewe',
      'passwordsNoMatch': 'Amagambo banga ntabwo ahurana',
      'confirmPasswordReq': 'Emeza ijambo banga ryawe',
      'errInvalidCredential': 'Imeyili cyangwa ijambo banga ntabwo ari byo.',
      'errWrongPassword': 'Ijambo banga sibyo.',
      'errInvalidEmail': 'Imeyili ntiyemewe.',
      'errUserDisabled': "Iy'i konti yahagaritswe.",
      'errTooManyRequests': 'Wagerageje kenshi. Gerageza nyuma.',
      'errSignInFailed': 'Kwinjira byanze. Subiramo.',
      'errEmailInUse': 'Konti ifite iyi meyili isanzwe ibaho.',
      'errWeakPassword': 'Ijambo banga risumbya (nibura inyuguti 6).',
      'errOpNotAllowed': 'Iyandikisha ryahagaritswe. Wasiliana na tekinike.',
      'errRegFailed': 'Iyandikisha ryanze. Subiramo.', // ── Map screen ──
      'searchHintMap': 'Shakisha ahantu i Kigali...',
      'getDirections': 'Shakisha Inzira',
      'clearRoute': 'Siba Inzira',
      'myLocation': 'Aho Ndi',
      'streetView': 'Kureba Umuhanda',
      'satelliteView': 'Kureba kwa Satelite',
      'showingFilter': 'Erekana',
      'directionsTitle': 'Tegura Inzira Yawe',
      'yourLocation': 'Aho uri',
      'gettingLocation': 'Gushakisha aho uri...',
      'searchDestination': 'Shakisha aho ugiye...',
      'noLocationWarning': 'Aho uri ntiboneka. Fungura serivisi y\'aho uri.',
      // ── Listings / Directory screen ──
      'listingsTitle': 'Inyandiko',
      'searchHintDirectory': 'Shakisha izina...',
      'filterAll': 'Byose',
      'failedLoad': 'Urutonde ntirushobotse gufungurwa',
      'retryLabel': 'Subiramo',
      'deleteListingTitle': 'Siba Inyandiko',
      'deleteConfirm': 'Siba "%s"? Ntushobora gusubiza.',
      'cancelLabel': 'Reka',
      'deleteLabel': 'Siba',
    },

    // ── Kiswahili ─────────────────────────────────────────────
    'sw': {
      'navHome': 'Nyumbani',
      'navMap': 'Ramani',
      'navListings': 'Orodha',
      'navSettings': 'Mipangilio',
      'homeWelcome': 'Karibu Kigali',
      'homeDiscover': 'Gundua Kigali',
      'catHealth': 'Afya',
      'catGovernment': 'Serikali',
      'catEntertainment': 'Burudani',
      'catEducation': 'Elimu',
      'catTourist': 'Kivutio cha Utalii',
      'searchHint': 'Tafuta...',
      'noListings': 'Hakuna orodha iliyopatikana',
      'settingsTitle': 'Mipangilio',
      'appearance': 'Muonekano',
      'theme': 'Mandhari',
      'themeLight': 'Mwanga',
      'themeDark': 'Giza',
      'themeSystem': 'Mfumo',
      'chooseTheme': 'Chagua Mandhari',
      'themeSystemDefault': 'Chaguo la Msingi',
      'notifications': 'Arifa',
      'notificationsDesc': 'Wezesha arifa za kusukuma',
      'language': 'Lugha',
      'chooseLanguage': 'Chagua Lugha',
      'location': 'Eneo',
      'useCurrentLocation': 'Tumia Eneo la Sasa',
      'useLocationDesc': 'Ruhusu programu kupata eneo la kifaa',
      'locationNotifs': 'Arifa za Eneo',
      'locationNotifsDesc': 'Pokea arifa kulingana na eneo lako',
      'account': 'Akaunti',
      'email': 'Barua pepe',
      'more': 'Zaidi',
      'about': 'Kuhusu',
      'version': 'Toleo 1.0.0',
      'termsPrivacy': 'Masharti na Faragha',
      'logOut': 'Toka',
      'edit': 'Hariri',
      'editProfile': 'Hariri Wasifu',
      'displayName': 'Jina la Kuonyesha',
      'yourFullName': 'Jina lako kamili',
      'saveChanges': 'Hifadhi Mabadiliko',
      'noNameSet': 'Hakuna jina lililowekwa',
      'cityGuide': 'Mwongozo wa Jiji',
      'forgotPassword': 'Umesahau nywila?',
      'signIn': 'Ingia',
      'noAccount': 'Huna akaunti?',
      'register': 'Jisajili',
      'password': 'Nywila',
      'emailRequired': 'Barua pepe inahitajika',
      'enterValidEmail': 'Ingiza barua pepe sahihi',
      'passwordRequired': 'Nywila inahitajika',
      'enterEmailFirst': 'Ingiza barua pepe yako kwanza',
      'resetEmailSent': 'Barua pepe ya kuweka upya nywila imetumwa!',
      'createAccount': 'Fungua Akaunti',
      'joinKigali': 'Jiunge na Kigali',
      'joinSubtitle': 'Fungua akaunti ili kuongeza na kusimamia orodha',
      'fullName': 'Jina Kamili',
      'confirmPassword': 'Thibitisha Nywila',
      'alreadyAccount': 'Una akaunti tayari?',
      'nameRequired': 'Jina linahitajika',
      'min6Chars': 'Angalau herufi 6 zinahitajika',
      'passwordsNoMatch': 'Nywila hazilingani',
      'confirmPasswordReq': 'Tafadhali thibitisha nywila',
      'errInvalidCredential': 'Barua pepe au nywila si sahihi.',
      'errWrongPassword': 'Nywila si sahihi.',
      'errInvalidEmail': 'Barua pepe si sahihi.',
      'errUserDisabled': 'Akaunti hii imezimwa.',
      'errTooManyRequests': 'Majaribio mengi. Jaribu tena baadaye.',
      'errSignInFailed': 'Kuingia kumeshindikana. Jaribu tena.',
      'errEmailInUse': 'Akaunti ipo tayari kwa barua pepe hii.',
      'errWeakPassword': 'Nywila ni dhaifu (angalau herufi 6).',
      'errOpNotAllowed': 'Usajili wa barua pepe haujawezeshwa.',
      'errRegFailed': 'Usajili umeshindikana. Jaribu tena.', // ── Map screen ──
      'searchHintMap': 'Tafuta mahali Kigali...',
      'getDirections': 'Pata Maelekezo',
      'clearRoute': 'Futa Njia',
      'myLocation': 'Eneo Langu',
      'streetView': 'Mtazamo wa Barabara',
      'satelliteView': 'Mtazamo wa Setilaiti',
      'showingFilter': 'Inaonyesha',
      'directionsTitle': 'Panga Safari Yako',
      'yourLocation': 'Eneo lako',
      'gettingLocation': 'Inapata eneo...',
      'searchDestination': 'Tafuta marudio...',
      'noLocationWarning': 'Eneo halipatikani. Washa huduma za eneo.',
      // ── Listings / Directory screen ──
      'listingsTitle': 'Saraka',
      'searchHintDirectory': 'Tafuta kwa jina...',
      'filterAll': 'Yote',
      'failedLoad': 'Imeshindwa kupakia orodha',
      'retryLabel': 'Jaribu tena',
      'deleteListingTitle': 'Futa Orodha',
      'deleteConfirm': 'Futa "%s"? Hii haiwezi kutenduliwa.',
      'cancelLabel': 'Ghairi',
      'deleteLabel': 'Futa',
    },

    // ── Deutsch ───────────────────────────────────────────────
    'de': {
      'navHome': 'Startseite',
      'navMap': 'Karte',
      'navListings': 'Anzeigen',
      'navSettings': 'Einstellungen',
      'homeWelcome': 'Willkommen in Kigali',
      'homeDiscover': 'Entdecke Kigali',
      'catHealth': 'Gesundheit',
      'catGovernment': 'Regierung',
      'catEntertainment': 'Unterhaltung',
      'catEducation': 'Bildung',
      'catTourist': 'Touristenattraktion',
      'searchHint': 'Suchen...',
      'noListings': 'Keine Einträge gefunden',
      'settingsTitle': 'Einstellungen',
      'appearance': 'Erscheinungsbild',
      'theme': 'Design',
      'themeLight': 'Hell',
      'themeDark': 'Dunkel',
      'themeSystem': 'System',
      'chooseTheme': 'Design wählen',
      'themeSystemDefault': 'Systemstandard',
      'notifications': 'Benachrichtigungen',
      'notificationsDesc': 'Push-Benachrichtigungen aktivieren',
      'language': 'Sprache',
      'chooseLanguage': 'Sprache wählen',
      'location': 'Standort',
      'useCurrentLocation': 'Aktuellen Standort verwenden',
      'useLocationDesc': 'App-Zugriff auf Gerätestandort erlauben',
      'locationNotifs': 'Standortbenachrichtigungen',
      'locationNotifsDesc': 'Standortbasierte Benachrichtigungen erhalten',
      'account': 'Konto',
      'email': 'E-Mail',
      'more': 'Mehr',
      'about': 'Über',
      'version': 'Version 1.0.0',
      'termsPrivacy': 'AGB & Datenschutz',
      'logOut': 'Abmelden',
      'edit': 'Bearbeiten',
      'editProfile': 'Profil bearbeiten',
      'displayName': 'Anzeigename',
      'yourFullName': 'Ihr vollständiger Name',
      'saveChanges': 'Änderungen speichern',
      'noNameSet': 'Kein Name festgelegt',
      'cityGuide': 'Stadtführer',
      'forgotPassword': 'Passwort vergessen?',
      'signIn': 'Anmelden',
      'noAccount': 'Noch kein Konto?',
      'register': 'Registrieren',
      'password': 'Passwort',
      'emailRequired': 'E-Mail ist erforderlich',
      'enterValidEmail': 'Gültige E-Mail eingeben',
      'passwordRequired': 'Passwort ist erforderlich',
      'enterEmailFirst': 'Gib zuerst deine E-Mail-Adresse ein',
      'resetEmailSent': 'Passwort-Reset-E-Mail gesendet!',
      'createAccount': 'Konto erstellen',
      'joinKigali': 'Kigali beitreten',
      'joinSubtitle':
          'Erstelle ein Konto, um Einträge hinzuzufügen und zu verwalten',
      'fullName': 'Vollständiger Name',
      'confirmPassword': 'Passwort bestätigen',
      'alreadyAccount': 'Bereits ein Konto?',
      'nameRequired': 'Name ist erforderlich',
      'min6Chars': 'Mindestens 6 Zeichen erforderlich',
      'passwordsNoMatch': 'Passwörter stimmen nicht überein',
      'confirmPasswordReq': 'Bitte bestätige dein Passwort',
      'errInvalidCredential': 'Ungültige E-Mail oder Passwort.',
      'errWrongPassword': 'Falsches Passwort.',
      'errInvalidEmail': 'Ungültige E-Mail-Adresse.',
      'errUserDisabled': 'Dieses Konto wurde deaktiviert.',
      'errTooManyRequests': 'Zu viele Versuche. Versuche es später.',
      'errSignInFailed': 'Anmeldung fehlgeschlagen. Bitte versuche es erneut.',
      'errEmailInUse': 'Ein Konto für diese E-Mail existiert bereits.',
      'errWeakPassword': 'Passwort zu schwach (mindestens 6 Zeichen).',
      'errOpNotAllowed': 'E-Mail-Anmeldung ist nicht aktiviert.',
      'errRegFailed':
          'Registrierung fehlgeschlagen. Bitte versuche es erneut.', // ── Map screen ──
      'searchHintMap': 'Ort in Kigali suchen...',
      'getDirections': 'Route berechnen',
      'clearRoute': 'Route löschen',
      'myLocation': 'Mein Standort',
      'streetView': 'Straßenansicht',
      'satelliteView': 'Satellitenansicht',
      'showingFilter': 'Zeigt',
      'directionsTitle': 'Route planen',
      'yourLocation': 'Ihr Standort',
      'gettingLocation': 'Standort wird ermittelt...',
      'searchDestination': 'Ziel suchen...',
      'noLocationWarning':
          'Standort nicht verfügbar. Aktiviere Ortungsdienste.',
      // ── Listings / Directory screen ──
      'listingsTitle': 'Verzeichnis',
      'searchHintDirectory': 'Nach Name suchen...',
      'filterAll': 'Alle',
      'failedLoad': 'Einträge konnten nicht geladen werden',
      'retryLabel': 'Erneut versuchen',
      'deleteListingTitle': 'Eintrag löschen',
      'deleteConfirm':
          '"%s" löschen? Dies kann nicht rückgängig gemacht werden.',
      'cancelLabel': 'Abbrechen',
      'deleteLabel': 'Löschen',
    },

    // ── Español ───────────────────────────────────────────────
    'es': {
      'navHome': 'Inicio',
      'navMap': 'Mapa',
      'navListings': 'Listados',
      'navSettings': 'Configuración',
      'homeWelcome': 'Bienvenido a Kigali',
      'homeDiscover': 'Descubre Kigali',
      'catHealth': 'Salud',
      'catGovernment': 'Gobierno',
      'catEntertainment': 'Entretenimiento',
      'catEducation': 'Educación',
      'catTourist': 'Atracción Turística',
      'searchHint': 'Buscar...',
      'noListings': 'No se encontraron listados',
      'settingsTitle': 'Configuración',
      'appearance': 'Apariencia',
      'theme': 'Tema',
      'themeLight': 'Claro',
      'themeDark': 'Oscuro',
      'themeSystem': 'Sistema',
      'chooseTheme': 'Elegir tema',
      'themeSystemDefault': 'Predeterminado del sistema',
      'notifications': 'Notificaciones',
      'notificationsDesc': 'Activar notificaciones push',
      'language': 'Idioma',
      'chooseLanguage': 'Elegir idioma',
      'location': 'Ubicación',
      'useCurrentLocation': 'Usar ubicación actual',
      'useLocationDesc':
          'Permitir a la app acceder a la ubicación del dispositivo',
      'locationNotifs': 'Notificaciones de ubicación',
      'locationNotifsDesc': 'Recibir notificaciones según tu ubicación',
      'account': 'Cuenta',
      'email': 'Correo electrónico',
      'more': 'Más',
      'about': 'Acerca de',
      'version': 'Versión 1.0.0',
      'termsPrivacy': 'Términos y privacidad',
      'logOut': 'Cerrar sesión',
      'edit': 'Editar',
      'editProfile': 'Editar perfil',
      'displayName': 'Nombre para mostrar',
      'yourFullName': 'Tu nombre completo',
      'saveChanges': 'Guardar cambios',
      'noNameSet': 'Sin nombre establecido',
      'cityGuide': 'Guía de la Ciudad',
      'forgotPassword': '¿Olvidaste la contraseña?',
      'signIn': 'Iniciar sesión',
      'noAccount': '¿No tienes cuenta?',
      'register': 'Registrarse',
      'password': 'Contraseña',
      'emailRequired': 'El correo electrónico es obligatorio',
      'enterValidEmail': 'Ingresa un correo electrónico válido',
      'passwordRequired': 'La contraseña es obligatoria',
      'enterEmailFirst': 'Ingresa tu dirección de correo primero',
      'resetEmailSent': '¡Correo de restablecimiento enviado!',
      'createAccount': 'Crear cuenta',
      'joinKigali': 'Únete a Kigali',
      'joinSubtitle': 'Crea una cuenta para añadir y gestionar listados',
      'fullName': 'Nombre completo',
      'confirmPassword': 'Confirmar contraseña',
      'alreadyAccount': '¿Ya tienes cuenta?',
      'nameRequired': 'El nombre es obligatorio',
      'min6Chars': 'Se requieren al menos 6 caracteres',
      'passwordsNoMatch': 'Las contraseñas no coinciden',
      'confirmPasswordReq': 'Por favor confirma tu contraseña',
      'errInvalidCredential': 'Correo o contraseña inválidos.',
      'errWrongPassword': 'Contraseña incorrecta.',
      'errInvalidEmail': 'Dirección de correo electrónico inválida.',
      'errUserDisabled': 'Esta cuenta ha sido deshabilitada.',
      'errTooManyRequests': 'Demasiados intentos. Inténtalo más tarde.',
      'errSignInFailed': 'Error al iniciar sesión. Inténtalo de nuevo.',
      'errEmailInUse': 'Ya existe una cuenta para este correo.',
      'errWeakPassword': 'La contraseña es débil (mínimo 6 caracteres).',
      'errOpNotAllowed': 'El registro por correo no está habilitado.',
      'errRegFailed': 'Error en el registro. Inténtalo de nuevo.',
      // ── Map screen ──
      'searchHintMap': 'Buscar un lugar en Kigali...',
      'getDirections': 'Obtener indicaciones',
      'clearRoute': 'Borrar ruta',
      'myLocation': 'Mi ubicación',
      'streetView': 'Vista de calle',
      'satelliteView': 'Vista satelital',
      'showingFilter': 'Mostrando',
      'directionsTitle': 'Planifica tu ruta',
      'yourLocation': 'Tu ubicación',
      'gettingLocation': 'Obteniendo ubicación...',
      'searchDestination': 'Buscar destino...',
      'noLocationWarning':
          'Ubicación no disponible. Activa los servicios de ubicación.',
      // ── Listings / Directory screen ──
      'listingsTitle': 'Directorio',
      'searchHintDirectory': 'Buscar por nombre...',
      'filterAll': 'Todos',
      'failedLoad': 'Error al cargar los listados',
      'retryLabel': 'Reintentar',
      'deleteListingTitle': 'Eliminar listado',
      'deleteConfirm': '¿Eliminar "%s"? Esta acción no se puede deshacer.',
      'cancelLabel': 'Cancelar',
      'deleteLabel': 'Eliminar',
    },
  };

  static const _subcategoryStrings = <String, Map<String, String>>{
    'en': {
      'Hospitals': 'Hospitals',
      'Clinics': 'Clinics',
      'Pharmacies': 'Pharmacies',
      'Polyclinics': 'Polyclinics',
      'Dispensaries': 'Dispensaries',
      'Specialized Clinics': 'Specialized Clinics',
      'Health Insurance Offices': 'Health Insurance Offices',
      'District Offices': 'District Offices',
      'Province Offices': 'Province Offices',
      'Sector Offices': 'Sector Offices',
      'Cell Offices': 'Cell Offices',
      'Village Offices': 'Village Offices',
      'Police Stations': 'Police Stations',
      'RIB Stations': 'RIB Stations',
      "Ministers' Offices": "Ministers' Offices",
      'Restaurants': 'Restaurants',
      'Cafes': 'Cafes',
      'Hotels': 'Hotels',
      'Lodges': 'Lodges',
      'Stadiums': 'Stadiums',
      'Playgrounds': 'Playgrounds',
      'Cinemas': 'Cinemas',
      'Nightlife': 'Nightlife',
      'Markets': 'Markets',
      'Supermarkets': 'Supermarkets',
      'Schools': 'Schools',
      'Universities': 'Universities',
      'Libraries': 'Libraries',
      'Education Centers': 'Education Centers',
      'Training Centers': 'Training Centers',
      'Museums': 'Museums',
      'Genocide Memorials': 'Genocide Memorials',
      'Parks': 'Parks',
      'Cultural Sites': 'Cultural Sites',
      'Viewpoints': 'Viewpoints',
      'Nature Reserves': 'Nature Reserves',
    },
    'fr': {
      'Hospitals': 'Hôpitaux',
      'Clinics': 'Cliniques',
      'Pharmacies': 'Pharmacies',
      'Polyclinics': 'Polycliniques',
      'Dispensaries': 'Dispensaires',
      'Specialized Clinics': 'Cliniques spécialisées',
      'Health Insurance Offices': "Bureaux d'assurance maladie",
      'District Offices': 'Bureaux de District',
      'Province Offices': 'Bureaux de Province',
      'Sector Offices': 'Bureaux de Secteur',
      'Cell Offices': 'Bureaux de Cellule',
      'Village Offices': 'Bureaux de Village',
      'Police Stations': 'Postes de police',
      'RIB Stations': 'Stations RIB',
      "Ministers' Offices": 'Bureaux des Ministres',
      'Restaurants': 'Restaurants',
      'Cafes': 'Cafés',
      'Hotels': 'Hôtels',
      'Lodges': 'Lodges',
      'Stadiums': 'Stades',
      'Playgrounds': 'Aires de jeux',
      'Cinemas': 'Cinémas',
      'Nightlife': 'Vie nocturne',
      'Markets': 'Marchés',
      'Supermarkets': 'Supermarchés',
      'Schools': 'Écoles',
      'Universities': 'Universités',
      'Libraries': 'Bibliothèques',
      'Education Centers': 'Centres éducatifs',
      'Training Centers': 'Centres de formation',
      'Museums': 'Musées',
      'Genocide Memorials': 'Mémoriaux du génocide',
      'Parks': 'Parcs',
      'Cultural Sites': 'Sites culturels',
      'Viewpoints': 'Points de vue',
      'Nature Reserves': 'Réserves naturelles',
    },
    'rw': {
      'Hospitals': 'Ibitaro',
      'Clinics': 'Kliniki',
      'Pharmacies': 'Apaotekayi',
      'Polyclinics': 'Polikilniki',
      'Dispensaries': 'Dispenseri',
      'Specialized Clinics': 'Kliniki Zihariye',
      'Health Insurance Offices': "Ibiro bya Mutuelle de Santé",
      'District Offices': 'Ibiro bya Akarere',
      'Province Offices': 'Ibiro bya Intara',
      'Sector Offices': 'Ibiro bya Umurenge',
      'Cell Offices': 'Ibiro bya Akagari',
      'Village Offices': "Ibiro by'Umudugudu",
      'Police Stations': 'Akarere ka Polisi',
      'RIB Stations': 'Ibiro bya RIB',
      "Ministers' Offices": "Ibiro by'Abaminisitiri",
      'Restaurants': 'Resitora',
      'Cafes': 'Kafeteriya',
      'Hotels': 'Hoteli',
      'Lodges': 'Loji',
      'Stadiums': "Inyubako y'Imikino",
      'Playgrounds': "Ibibuga by'Imikino",
      'Cinemas': 'Sinema',
      'Nightlife': 'Amafete ya Nijoro',
      'Markets': 'Amasoko',
      'Supermarkets': 'Siperemarket',
      'Schools': 'Amashuri',
      'Universities': 'Kaminuza',
      'Libraries': 'Ibiburotekar',
      'Education Centers': "Amahanga y'Uburezi",
      'Training Centers': "Amahanga y'Amahugurwa",
      'Museums': 'Inzu Ndangamubanyi',
      'Genocide Memorials': "Ibuka ry'Itsembabwoko",
      'Parks': 'Amashyamba',
      'Cultural Sites': "Ibirindiro by'Umuco",
      'Viewpoints': 'Aho Kureba',
      'Nature Reserves': 'Ivuriro rya Kamere',
    },
    'sw': {
      'Hospitals': 'Hospitali',
      'Clinics': 'Kliniki',
      'Pharmacies': 'Maduka ya Dawa',
      'Polyclinics': 'Polikiniki',
      'Dispensaries': 'Zahanati',
      'Specialized Clinics': 'Kliniki Maalum',
      'Health Insurance Offices': 'Ofisi za Bima ya Afya',
      'District Offices': 'Ofisi za Wilaya',
      'Province Offices': 'Ofisi za Mkoa',
      'Sector Offices': 'Ofisi za Sekta',
      'Cell Offices': 'Ofisi za Mtaa',
      'Village Offices': 'Ofisi za Kijiji',
      'Police Stations': 'Vituo vya Polisi',
      'RIB Stations': 'Vituo vya RIB',
      "Ministers' Offices": 'Ofisi za Mawaziri',
      'Restaurants': 'Mikahawa',
      'Cafes': 'Mikahawa ya Kahawa',
      'Hotels': 'Hoteli',
      'Lodges': 'Nyumba za Kulala',
      'Stadiums': 'Viwanja vya Michezo',
      'Playgrounds': 'Viwanja vya Mchezo',
      'Cinemas': 'Sinema',
      'Nightlife': 'Burudani ya Usiku',
      'Markets': 'Masoko',
      'Supermarkets': 'Madukani Makubwa',
      'Schools': 'Shule',
      'Universities': 'Vyuo Vikuu',
      'Libraries': 'Maktaba',
      'Education Centers': 'Vituo vya Elimu',
      'Training Centers': 'Vituo vya Mafunzo',
      'Museums': 'Makumbusho',
      'Genocide Memorials': 'Makumbusho ya Mauaji ya Kimbari',
      'Parks': 'Mbuga',
      'Cultural Sites': 'Maeneo ya Utamaduni',
      'Viewpoints': 'Maeneo ya Maoni',
      'Nature Reserves': 'Hifadhi za Asili',
    },
    'de': {
      'Hospitals': 'Krankenhäuser',
      'Clinics': 'Kliniken',
      'Pharmacies': 'Apotheken',
      'Polyclinics': 'Polikliniken',
      'Dispensaries': 'Dispensarien',
      'Specialized Clinics': 'Fachkliniken',
      'Health Insurance Offices': 'Krankenkassen',
      'District Offices': 'Bezirksämter',
      'Province Offices': 'Provinzbüros',
      'Sector Offices': 'Sektorbüros',
      'Cell Offices': 'Zellenbüros',
      'Village Offices': 'Dorfbüros',
      'Police Stations': 'Polizeistationen',
      'RIB Stations': 'RIB-Stationen',
      "Ministers' Offices": 'Ministerbüros',
      'Restaurants': 'Restaurants',
      'Cafes': 'Cafés',
      'Hotels': 'Hotels',
      'Lodges': 'Lodges',
      'Stadiums': 'Stadien',
      'Playgrounds': 'Spielplätze',
      'Cinemas': 'Kinos',
      'Nightlife': 'Nachtleben',
      'Markets': 'Märkte',
      'Supermarkets': 'Supermärkte',
      'Schools': 'Schulen',
      'Universities': 'Universitäten',
      'Libraries': 'Bibliotheken',
      'Education Centers': 'Bildungszentren',
      'Training Centers': 'Ausbildungszentren',
      'Museums': 'Museen',
      'Genocide Memorials': 'Völkermord-Gedenkstätten',
      'Parks': 'Parks',
      'Cultural Sites': 'Kulturstätten',
      'Viewpoints': 'Aussichtspunkte',
      'Nature Reserves': 'Naturschutzgebiete',
    },
    'es': {
      'Hospitals': 'Hospitales',
      'Clinics': 'Clínicas',
      'Pharmacies': 'Farmacias',
      'Polyclinics': 'Policlínicas',
      'Dispensaries': 'Dispensarios',
      'Specialized Clinics': 'Clínicas Especializadas',
      'Health Insurance Offices': 'Oficinas de Seguro Médico',
      'District Offices': 'Oficinas de Distrito',
      'Province Offices': 'Oficinas de Provincia',
      'Sector Offices': 'Oficinas de Sector',
      'Cell Offices': 'Oficinas de Célula',
      'Village Offices': 'Oficinas de Aldea',
      'Police Stations': 'Comisarías de Policía',
      'RIB Stations': 'Estaciones RIB',
      "Ministers' Offices": 'Oficinas Ministeriales',
      'Restaurants': 'Restaurantes',
      'Cafes': 'Cafeterías',
      'Hotels': 'Hoteles',
      'Lodges': 'Alojamientos',
      'Stadiums': 'Estadios',
      'Playgrounds': 'Parques Infantiles',
      'Cinemas': 'Cines',
      'Nightlife': 'Vida Nocturna',
      'Markets': 'Mercados',
      'Supermarkets': 'Supermercados',
      'Schools': 'Escuelas',
      'Universities': 'Universidades',
      'Libraries': 'Bibliotecas',
      'Education Centers': 'Centros Educativos',
      'Training Centers': 'Centros de Capacitación',
      'Museums': 'Museos',
      'Genocide Memorials': 'Memoriales del Genocidio',
      'Parks': 'Parques',
      'Cultural Sites': 'Sitios Culturales',
      'Viewpoints': 'Miradores',
      'Nature Reserves': 'Reservas Naturales',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'rw', 'sw', 'de', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
