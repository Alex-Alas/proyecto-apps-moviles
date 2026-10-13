import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Hamtimer'**
  String get appTitle;

  /// No description provided for @navTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get navTasks;

  /// No description provided for @navPomodoro.
  ///
  /// In es, this message translates to:
  /// **'Pomodoro'**
  String get navPomodoro;

  /// No description provided for @navNewTask.
  ///
  /// In es, this message translates to:
  /// **'Nueva'**
  String get navNewTask;

  /// No description provided for @tasksTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis actividades'**
  String get tasksTitle;

  /// No description provided for @tasksSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu plan de enfoque, ordenado por vencimiento'**
  String get tasksSubtitle;

  /// No description provided for @dailyProgress.
  ///
  /// In es, this message translates to:
  /// **'Avance del día'**
  String get dailyProgress;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get filterToday;

  /// No description provided for @filterCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completadas'**
  String get filterCompleted;

  /// No description provided for @formTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva actividad'**
  String get formTitle;

  /// No description provided for @formFocusObjective.
  ///
  /// In es, this message translates to:
  /// **'Objetivo de enfoque'**
  String get formFocusObjective;

  /// No description provided for @formCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get formCategory;

  /// No description provided for @formEstimatedDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración estimada'**
  String get formEstimatedDuration;

  /// No description provided for @formPriority.
  ///
  /// In es, this message translates to:
  /// **'Nivel de prioridad'**
  String get formPriority;

  /// No description provided for @formSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get formSchedule;

  /// No description provided for @formSubmit.
  ///
  /// In es, this message translates to:
  /// **'Crear actividad'**
  String get formSubmit;

  /// No description provided for @pomodoroSessionTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas de la sesión'**
  String get pomodoroSessionTasks;

  /// No description provided for @pomodoroAddTask.
  ///
  /// In es, this message translates to:
  /// **'Agregar tarea'**
  String get pomodoroAddTask;

  /// No description provided for @comingSoon.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get comingSoon;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
