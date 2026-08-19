import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Usta Kapında'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginWithApple;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get createAccount;

  /// No description provided for @findCraftsman.
  ///
  /// In en, this message translates to:
  /// **'The easiest way to find a craftsman'**
  String get findCraftsman;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @selectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get selectAccountType;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'I am a Customer'**
  String get customer;

  /// No description provided for @lookingForCraftsman.
  ///
  /// In en, this message translates to:
  /// **'I\'m looking for a craftsman'**
  String get lookingForCraftsman;

  /// No description provided for @craftsman.
  ///
  /// In en, this message translates to:
  /// **'Craftsman'**
  String get craftsman;

  /// No description provided for @lookingForJob.
  ///
  /// In en, this message translates to:
  /// **'I\'m looking for work'**
  String get lookingForJob;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueButton;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @addressInformation.
  ///
  /// In en, this message translates to:
  /// **'Address Information'**
  String get addressInformation;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @neighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get neighborhood;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get address;

  /// No description provided for @craftsmanInformation.
  ///
  /// In en, this message translates to:
  /// **'Craftsman Information'**
  String get craftsmanInformation;

  /// No description provided for @professions.
  ///
  /// In en, this message translates to:
  /// **'Professions'**
  String get professions;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'Experience (Years)'**
  String get experienceYears;

  /// No description provided for @aboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell Us About Yourself'**
  String get aboutYourself;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @createCraftsmanAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a craftsman account'**
  String get createCraftsmanAccount;

  /// No description provided for @createCustomerAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a customer account'**
  String get createCustomerAccount;

  /// No description provided for @kvkk.
  ///
  /// In en, this message translates to:
  /// **'KVKK Information Notice'**
  String get kvkk;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @readAndAccept.
  ///
  /// In en, this message translates to:
  /// **' I have read and accept.'**
  String get readAndAccept;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @requiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get requiredFields;

  /// No description provided for @acceptLegalDocuments.
  ///
  /// In en, this message translates to:
  /// **'You must accept the KVKK Information Notice, Terms of Use and Privacy Policy.'**
  String get acceptLegalDocuments;

  /// No description provided for @verificationCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification code could not be sent.'**
  String get verificationCodeFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration could not be completed.'**
  String get registrationFailed;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email. Please use another email or go to the login page.'**
  String get emailAlreadyExists;

  /// No description provided for @phoneAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this phone number. Please use another phone number.'**
  String get phoneAlreadyExists;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name.'**
  String get firstNameRequired;

  /// No description provided for @firstNameMin.
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 3 characters.'**
  String get firstNameMin;

  /// No description provided for @firstNameMax.
  ///
  /// In en, this message translates to:
  /// **'First name can be at most 20 characters.'**
  String get firstNameMax;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name.'**
  String get lastNameRequired;

  /// No description provided for @lastNameMin.
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 3 characters.'**
  String get lastNameMin;

  /// No description provided for @lastNameMax.
  ///
  /// In en, this message translates to:
  /// **'Last name can be at most 30 characters.'**
  String get lastNameMax;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get emailRequired;

  /// No description provided for @emailMin.
  ///
  /// In en, this message translates to:
  /// **'Email must be at least 10 characters.'**
  String get emailMin;

  /// No description provided for @emailMax.
  ///
  /// In en, this message translates to:
  /// **'Email can be at most 50 characters.'**
  String get emailMax;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get phoneRequired;

  /// No description provided for @phoneMin.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 10 characters.'**
  String get phoneMin;

  /// No description provided for @phoneMax.
  ///
  /// In en, this message translates to:
  /// **'Phone number can be at most 20 characters.'**
  String get phoneMax;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Only numbers and the + sign can be used.'**
  String get phoneInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get passwordRequired;

  /// No description provided for @passwordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMin;

  /// No description provided for @passwordMax.
  ///
  /// In en, this message translates to:
  /// **'Password can be at most 50 characters.'**
  String get passwordMax;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password again.'**
  String get confirmPasswordRequired;

  /// No description provided for @confirmPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation must be at least 6 characters.'**
  String get confirmPasswordMin;

  /// No description provided for @confirmPasswordMax.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation can be at most 50 characters.'**
  String get confirmPasswordMax;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @neighborhoodRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your neighborhood.'**
  String get neighborhoodRequired;

  /// No description provided for @neighborhoodMin.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood must be at least 5 characters.'**
  String get neighborhoodMin;

  /// No description provided for @neighborhoodMax.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood can be at most 30 characters.'**
  String get neighborhoodMax;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full address.'**
  String get addressRequired;

  /// No description provided for @addressMin.
  ///
  /// In en, this message translates to:
  /// **'Full address must be at least 10 characters.'**
  String get addressMin;

  /// No description provided for @addressMax.
  ///
  /// In en, this message translates to:
  /// **'Full address can be at most 60 characters.'**
  String get addressMax;

  /// No description provided for @experienceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your years of experience.'**
  String get experienceRequired;

  /// No description provided for @experienceDigits.
  ///
  /// In en, this message translates to:
  /// **'Only numbers can be entered.'**
  String get experienceDigits;

  /// No description provided for @experienceRange.
  ///
  /// In en, this message translates to:
  /// **'Experience must be between 1 and 100 years.'**
  String get experienceRange;

  /// No description provided for @aboutRequired.
  ///
  /// In en, this message translates to:
  /// **'Please introduce yourself.'**
  String get aboutRequired;

  /// No description provided for @aboutMin.
  ///
  /// In en, this message translates to:
  /// **'You must enter at least 10 characters.'**
  String get aboutMin;

  /// No description provided for @aboutMax.
  ///
  /// In en, this message translates to:
  /// **'You can enter at most 60 characters.'**
  String get aboutMax;

  /// No description provided for @selectCityFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a city first.'**
  String get selectCityFirst;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @whatServiceDoYouNeed.
  ///
  /// In en, this message translates to:
  /// **'What service do you need today?'**
  String get whatServiceDoYouNeed;

  /// No description provided for @craftsmanAtYourDoor.
  ///
  /// In en, this message translates to:
  /// **'The craftsman you need is right at your door'**
  String get craftsmanAtYourDoor;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @viewListings.
  ///
  /// In en, this message translates to:
  /// **'VIEW LISTINGS'**
  String get viewListings;

  /// No description provided for @postListing.
  ///
  /// In en, this message translates to:
  /// **'POST A JOB'**
  String get postListing;

  /// No description provided for @serviceCategories.
  ///
  /// In en, this message translates to:
  /// **'Service Categories'**
  String get serviceCategories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @bestCraftsmen.
  ///
  /// In en, this message translates to:
  /// **'Best Craftsmen'**
  String get bestCraftsmen;

  /// No description provided for @discoverTopRatedCraftsmen.
  ///
  /// In en, this message translates to:
  /// **'Discover the highest-rated craftsmen in your area.'**
  String get discoverTopRatedCraftsmen;

  /// No description provided for @discoverCraftsmen.
  ///
  /// In en, this message translates to:
  /// **'Discover Craftsmen'**
  String get discoverCraftsmen;

  /// No description provided for @makeOffer.
  ///
  /// In en, this message translates to:
  /// **'Make an Offer'**
  String get makeOffer;

  /// No description provided for @plumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get plumbing;

  /// No description provided for @electricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricity;

  /// No description provided for @airConditioning.
  ///
  /// In en, this message translates to:
  /// **'Air Conditioning'**
  String get airConditioning;

  /// No description provided for @painting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get painting;

  /// No description provided for @furniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furniture;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// No description provided for @construction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get construction;

  /// No description provided for @roofing.
  ///
  /// In en, this message translates to:
  /// **'Roofing'**
  String get roofing;

  /// No description provided for @craftsmanPanel.
  ///
  /// In en, this message translates to:
  /// **'Craftsman Panel'**
  String get craftsmanPanel;

  /// No description provided for @noNewListingsToday.
  ///
  /// In en, this message translates to:
  /// **'There are no new listings today.'**
  String get noNewListingsToday;

  /// No description provided for @newListingsWaiting.
  ///
  /// In en, this message translates to:
  /// **'There are {count} new listings waiting for you today.'**
  String newListingsWaiting(int count);

  /// No description provided for @tokenBalance.
  ///
  /// In en, this message translates to:
  /// **'Token Balance'**
  String get tokenBalance;

  /// No description provided for @tokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get tokens;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @newJobs.
  ///
  /// In en, this message translates to:
  /// **'New Jobs'**
  String get newJobs;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @latestListings.
  ///
  /// In en, this message translates to:
  /// **'Latest Listings'**
  String get latestListings;

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'There are no listings yet.'**
  String get noListingsYet;

  /// No description provided for @estimatedBudget.
  ///
  /// In en, this message translates to:
  /// **'Estimated Budget'**
  String get estimatedBudget;

  /// No description provided for @offerFee.
  ///
  /// In en, this message translates to:
  /// **'Offer Fee: 🪙 50 Tokens'**
  String get offerFee;

  /// No description provided for @insufficientTokens.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Tokens'**
  String get insufficientTokens;

  /// No description provided for @minimumTokensRequired.
  ///
  /// In en, this message translates to:
  /// **'You need at least 50 Tokens to send an offer.'**
  String get minimumTokensRequired;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @buyTokens.
  ///
  /// In en, this message translates to:
  /// **'Buy Tokens'**
  String get buyTokens;

  /// No description provided for @viewJobDetails.
  ///
  /// In en, this message translates to:
  /// **'View Job Details'**
  String get viewJobDetails;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @acceptedStatus.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get acceptedStatus;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @noOffersYet.
  ///
  /// In en, this message translates to:
  /// **'There are no offers yet.'**
  String get noOffersYet;

  /// No description provided for @jobListing.
  ///
  /// In en, this message translates to:
  /// **'Job Listing'**
  String get jobListing;

  /// No description provided for @myOffer.
  ///
  /// In en, this message translates to:
  /// **'My Offer'**
  String get myOffer;

  /// No description provided for @offerSent.
  ///
  /// In en, this message translates to:
  /// **'Offer sent'**
  String get offerSent;

  /// No description provided for @waitingForCustomerApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the customer to approve your offer.'**
  String get waitingForCustomerApproval;

  /// No description provided for @startJob.
  ///
  /// In en, this message translates to:
  /// **'Start Job'**
  String get startJob;

  /// No description provided for @cancelJob.
  ///
  /// In en, this message translates to:
  /// **'Cancel Job'**
  String get cancelJob;

  /// No description provided for @jobCancelled.
  ///
  /// In en, this message translates to:
  /// **'Job cancelled.'**
  String get jobCancelled;

  /// No description provided for @offerRejected.
  ///
  /// In en, this message translates to:
  /// **'Your offer was rejected.'**
  String get offerRejected;

  /// No description provided for @completeJob.
  ///
  /// In en, this message translates to:
  /// **'Complete Job'**
  String get completeJob;

  /// No description provided for @sendMessageToCustomer.
  ///
  /// In en, this message translates to:
  /// **'Send Message to Customer'**
  String get sendMessageToCustomer;

  /// No description provided for @reviewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Review Customer'**
  String get reviewCustomer;

  /// No description provided for @customerReviewed.
  ///
  /// In en, this message translates to:
  /// **'You reviewed this customer.'**
  String get customerReviewed;

  /// No description provided for @myOffers.
  ///
  /// In en, this message translates to:
  /// **'My Offers'**
  String get myOffers;

  /// No description provided for @pleaseWriteComment.
  ///
  /// In en, this message translates to:
  /// **'Please write a comment.'**
  String get pleaseWriteComment;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully.'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'{count} Stars'**
  String stars(int count);

  /// No description provided for @yourComment.
  ///
  /// In en, this message translates to:
  /// **'Your Comment'**
  String get yourComment;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'ABOUT US\nLast Updated: August 3, 2026\nUsta Kapında is a digital platform developed to provide fast, reliable, and easy access to the services people need.\nOur platform aims to make the process of receiving offers, communicating, and obtaining services easier by bringing customers and craftsmen from different professions together in a secure environment.\n\nOUR MISSION\nTo help our users easily reach reliable craftsmen and make the processes of receiving and providing services fast, transparent, and secure.\n\nOUR VISION\nTo become one of the most trusted service platforms in Türkiye and raise quality standards in the service industry by using technology.\n\nOUR VALUES\n• Trust\n• Transparency\n• Quality\n• Fast Service\n• User Satisfaction\n• Continuous Improvement\n\nWHY USTA KAPINDA?\n• Easy job posting\n• Fast offers\n• Reliable craftsman profiles\n• Review system\n• Real user experience\n• Modern and secure infrastructure\n\nFOR CUSTOMERS\n• Find a craftsman suitable for your needs.\n• Receive offers from different craftsmen.\n• Rate craftsmen based on their ratings.\n\nFOR CRAFTSMEN\n• Reach new customers.\n• Promote your services to a wider audience.\n• Manage your jobs through a single platform.\n\nSECURITY\nUsta Kapında places importance on protecting user information. Your data is stored on secure infrastructure and processed in accordance with applicable legislation.\n\nCONTACT\nEmail:\nsupport@ustakapinda.com\n\nThank you for choosing Usta Kapında.'**
  String get aboutText;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @completedJobs.
  ///
  /// In en, this message translates to:
  /// **'Completed Jobs'**
  String get completedJobs;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @editInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get editInformation;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @emailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'A verification link has been sent to the new email address.'**
  String get emailVerificationSent;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @updateEmail.
  ///
  /// In en, this message translates to:
  /// **'Update Email'**
  String get updateEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.'**
  String get passwordChangedSuccessfully;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noCommentsYet;

  /// No description provided for @createCraftsmanProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Craftsman Profile'**
  String get createCraftsmanProfile;

  /// No description provided for @createCustomerProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Customer Profile'**
  String get createCustomerProfile;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @profileEditing.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditing;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @fixInvalidFields.
  ///
  /// In en, this message translates to:
  /// **'Please correct the invalid fields.'**
  String get fixInvalidFields;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdated;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile could not be updated: {error}'**
  String profileUpdateFailed(String error);

  /// No description provided for @existingAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Login to Existing Account'**
  String get existingAccountLogin;

  /// No description provided for @userInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'User information could not be found.'**
  String get userInfoNotFound;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get loginFailed;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any favorites yet.'**
  String get noFavoritesYet;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {name} 👋'**
  String greeting(String name);

  /// No description provided for @searchCraftsmanHint.
  ///
  /// In en, this message translates to:
  /// **'Search craftsman'**
  String get searchCraftsmanHint;

  /// No description provided for @postJob.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get postJob;

  /// No description provided for @newJobListing.
  ///
  /// In en, this message translates to:
  /// **'New Job Listing'**
  String get newJobListing;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @jobTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Home electrical installation'**
  String get jobTitleHint;

  /// No description provided for @jobTitleLengthError.
  ///
  /// In en, this message translates to:
  /// **'Job title must be between 5 and 50 characters.'**
  String get jobTitleLengthError;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a category'**
  String get selectCategoryHint;

  /// No description provided for @selectCityHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a city'**
  String get selectCityHint;

  /// No description provided for @selectDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a district'**
  String get selectDistrictHint;

  /// No description provided for @startJobWhen.
  ///
  /// In en, this message translates to:
  /// **'When Will the Job Start?'**
  String get startJobWhen;

  /// No description provided for @daysRange.
  ///
  /// In en, this message translates to:
  /// **'1 - 100 days'**
  String get daysRange;

  /// No description provided for @daysRangeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a value between 1 and 100 days.'**
  String get daysRangeError;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @jobDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the job in detail...'**
  String get jobDetailsHint;

  /// No description provided for @enterJobDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter the job details.'**
  String get enterJobDetails;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget (₺)'**
  String get budget;

  /// No description provided for @publishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing...'**
  String get publishing;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH LISTING'**
  String get publishListing;

  /// No description provided for @listingPublished.
  ///
  /// In en, this message translates to:
  /// **'Job listing published successfully.'**
  String get listingPublished;

  /// No description provided for @listingInfo.
  ///
  /// In en, this message translates to:
  /// **'After your listing is published, suitable craftsmen will be able to see it and send you offers.'**
  String get listingInfo;

  /// No description provided for @sessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found.'**
  String get sessionNotFound;

  /// No description provided for @searchListings.
  ///
  /// In en, this message translates to:
  /// **'Search Listings'**
  String get searchListings;

  /// No description provided for @noListingsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No listings match the filters.'**
  String get noListingsMatchFilters;

  /// No description provided for @changeFiltersAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Change the filters and try again.'**
  String get changeFiltersAndTryAgain;

  /// No description provided for @published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get published;

  /// No description provided for @viewListing.
  ///
  /// In en, this message translates to:
  /// **'View Listing'**
  String get viewListing;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @kvkkText.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL DATA PROTECTION LAW NO. 6698 (KVKK)\nPRIVACY NOTICE\n\nLast Updated: August 3, 2026\n\nThis privacy notice has been prepared to inform you about the personal data processed by the Usta Kapında application.\n\n1. Data Controller\n\nThe Usta Kapında application processes your personal data as the data controller within the scope of the Law No. 6698 on the Protection of Personal Data.\n\n2. Personal Data Processed\n\nThe following information may be processed while you use the application:\n\n• First and Last Name\n• Phone Number\n• Email Address\n• Profile Photo\n• City / District Information\n• Full Address\n• Profession Information\n• Experience Information\n• About Me Information\n• Job Listings\n• Offer Information\n• Messaging Data\n• Reviews and Ratings\n• Notification Token (Firebase Cloud Messaging)\n• Device Information\n• Location Information (only if permission is granted)\n\n3. Purposes of Processing Personal Data\n\nThe collected personal data is processed for the following purposes:\n\n• Creating a user account,\n• Identity verification,\n• Matching customers with craftsmen,\n• Publishing job listings,\n• Managing offer processes,\n• Providing messaging services,\n• Sending notifications,\n• Ensuring account security,\n• Preventing fraud,\n• Improving user experience,\n• Fulfilling legal obligations.\n\n4. Transfer of Personal Data\n\nYour personal data may be transferred, within the framework of applicable legislation, to:\n\n• Public institutions and organizations legally authorized to receive such data,\n• Courts or official authorities upon request,\n• Technical infrastructure providers used to provide the service (such as Firebase).\n\n5. Method of Collecting Personal Data\n\nData is collected electronically through:\n\n• Membership procedures,\n• Profile editing,\n• Job listings,\n• Creating offers,\n• Messaging,\n• Notification services,\n• Application usage activities.\n\n6. Retention Period\n\nPersonal data is retained only for as long as necessary. When the periods prescribed by applicable legislation expire or the purpose of processing ceases to exist, the data is deleted, destroyed, or anonymized.\n\n7. Your Rights Under KVKK\n\nWithin the scope of Article 11 of the KVKK, users may:\n\n• Learn whether their personal data is being processed,\n• Request information about processed data,\n• Request correction of inaccurate or incomplete information,\n• Request deletion or destruction of their data,\n• Request compensation for damages if the processing is unlawful.\n\n8. Application\n\nYou may submit your requests under the KVKK through the following email address.\n\nsupport@ustakapida.org\n\n9. Updates\n\nThis privacy notice may be updated when necessary. The current version will always be published within the application.\n\nBy using the Usta Kapında application, you acknowledge that you have read this Privacy Notice and have been informed that your personal data may be processed within the scope specified above.'**
  String get kvkkText;

  /// No description provided for @loginEmailOrPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number and password.'**
  String get loginEmailOrPhoneRequired;

  /// No description provided for @phoneAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account was found for this phone number.'**
  String get phoneAccountNotFound;

  /// No description provided for @phoneVerificationServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The phone verification service could not be reached.'**
  String get phoneVerificationServiceUnavailable;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The password you entered is incorrect.\nIf you don\'t remember your password, you can use the \"Forgot Password\" option.'**
  String get wrongPassword;

  /// No description provided for @emailAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account was found with this email address.'**
  String get emailAccountNotFound;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmailAddress;

  /// No description provided for @invalidEmailOrPhonePassword.
  ///
  /// In en, this message translates to:
  /// **'Email/phone or password is incorrect.'**
  String get invalidEmailOrPhonePassword;

  /// No description provided for @tooManyLoginAttempts.
  ///
  /// In en, this message translates to:
  /// **'You have made too many failed login attempts. Please try again in a few minutes.'**
  String get tooManyLoginAttempts;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first.'**
  String get enterEmailFirst;

  /// No description provided for @codeCouldNotBeSent.
  ///
  /// In en, this message translates to:
  /// **'The code could not be sent.'**
  String get codeCouldNotBeSent;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFound;

  /// No description provided for @newIncomingOffers.
  ///
  /// In en, this message translates to:
  /// **'New Incoming Offers'**
  String get newIncomingOffers;

  /// No description provided for @noMyListings.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any listings yet.'**
  String get noMyListings;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// No description provided for @removeListing.
  ///
  /// In en, this message translates to:
  /// **'Remove Listing'**
  String get removeListing;

  /// No description provided for @republishListing.
  ///
  /// In en, this message translates to:
  /// **'Republish Listing'**
  String get republishListing;

  /// No description provided for @listingRemoved.
  ///
  /// In en, this message translates to:
  /// **'Listing has been removed.'**
  String get listingRemoved;

  /// No description provided for @listingRepublished.
  ///
  /// In en, this message translates to:
  /// **'Listing has been republished.'**
  String get listingRepublished;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fillAllFields;

  /// No description provided for @passwordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Password could not be updated.'**
  String get passwordUpdateFailed;

  /// No description provided for @estimatedDurationRange.
  ///
  /// In en, this message translates to:
  /// **'The estimated duration must be between 1 and 100 days.'**
  String get estimatedDurationRange;

  /// No description provided for @offerMessageMin.
  ///
  /// In en, this message translates to:
  /// **'The offer message must be at least 20 characters.'**
  String get offerMessageMin;

  /// No description provided for @offerMessageMax.
  ///
  /// In en, this message translates to:
  /// **'The offer message can be at most 200 characters.'**
  String get offerMessageMax;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in first.'**
  String get loginRequired;

  /// No description provided for @alreadyOffered.
  ///
  /// In en, this message translates to:
  /// **'You have already made an offer for this listing.'**
  String get alreadyOffered;

  /// No description provided for @offerCouldNotBeSent.
  ///
  /// In en, this message translates to:
  /// **'The offer could not be sent.'**
  String get offerCouldNotBeSent;

  /// No description provided for @unauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Please log in again.'**
  String get unauthenticated;

  /// No description provided for @estimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Estimated Duration'**
  String get estimatedDuration;

  /// No description provided for @offerMessage.
  ///
  /// In en, this message translates to:
  /// **'Offer Message'**
  String get offerMessage;

  /// No description provided for @offerInformation.
  ///
  /// In en, this message translates to:
  /// **'After your offer is sent, the customer can review, accept, or reject your offer.'**
  String get offerInformation;

  /// No description provided for @privacyPolicyText.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY\n\nLast Updated: August 3, 2026\n\nAt Usta Kapında, we care about protecting the privacy of our users\' personal data. This policy explains what information may be collected while using our application, how it is used, and how it is protected.\n\n1. Information Collected\n\nThe following information may be collected while using the application:\n\n• First and Last Name\n• Phone Number\n• Email Address\n• Profile Photo\n• Address Information\n• City / District Information\n• Profession Information\n• Service History\n• Ratings and Reviews\n• Notification Token (FCM)\n• Device Information\n• Location Information (only if permission is granted)\n\n2. How We Use Information\n\nCollected information is used to;\n\n• Create your account,\n• Facilitate communication between customers and service providers,\n• Publish job listings,\n• Manage offer processes,\n• Send notifications,\n• Ensure account security,\n• Prevent fraud,\n• Improve service quality,\n• Fulfill legal obligations.\n\n3. Storage of Information\n\nPersonal data is stored on secure servers and necessary technical and administrative measures are taken against unauthorized access.\n\n4. Sharing of Information\n\nYour personal data;\n\n• Is not sold to third parties without your explicit consent.\n• Is not shared for advertising purposes.\n• May be shared with authorized public authorities when legally required.\n\n5. Notifications\n\nThe application may send notifications about job listings, offers, messages, and system announcements.\n\n6. Location Information\n\nLocation information is used only if you grant permission and is processed to provide you with more accurate services.\n\n7. Account Security\n\nUsers are responsible for the security of their passwords. If you notice any suspicious activity related to your account, you can contact our support team.\n\n8. User Rights\n\nUsers may;\n\n• View their information,\n• Update their information,\n• Freeze their account,\n• Delete their account,\n• Request deletion of their personal data.\n\n9. Policy Updates\n\nThis privacy policy may be updated when necessary. The current version will always be published within the application.\n\n10. Contact\n\nYou can contact us with any questions.\n\nEmail:\nsupport@ustakapida.org\n\nBy using the Usta Kapında application, you acknowledge that you have read and accepted this Privacy Policy.'**
  String get privacyPolicyText;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @supportCenter.
  ///
  /// In en, this message translates to:
  /// **'Support Center'**
  String get supportCenter;

  /// No description provided for @changeAccountType.
  ///
  /// In en, this message translates to:
  /// **'Change Account Type'**
  String get changeAccountType;

  /// No description provided for @accountActivity.
  ///
  /// In en, this message translates to:
  /// **'Account Activity'**
  String get accountActivity;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @searchCraftsmanTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a Craftsman'**
  String get searchCraftsmanTitle;

  /// No description provided for @searchServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Services'**
  String get searchServiceTitle;

  /// No description provided for @craftsmanSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a craftsman\'s name or profession...'**
  String get craftsmanSearchHint;

  /// No description provided for @searchCraftsmanButton.
  ///
  /// In en, this message translates to:
  /// **'FIND CRAFTSMAN'**
  String get searchCraftsmanButton;

  /// No description provided for @popularCategories.
  ///
  /// In en, this message translates to:
  /// **'Popular Categories'**
  String get popularCategories;

  /// No description provided for @featuredCraftsmen.
  ///
  /// In en, this message translates to:
  /// **'Featured Craftsmen'**
  String get featuredCraftsmen;

  /// No description provided for @topRatedCraftsmenFirst.
  ///
  /// In en, this message translates to:
  /// **'The highest-rated craftsmen are shown first.'**
  String get topRatedCraftsmenFirst;

  /// No description provided for @noCraftsmenFound.
  ///
  /// In en, this message translates to:
  /// **'No craftsmen found'**
  String get noCraftsmenFound;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @inFavorites.
  ///
  /// In en, this message translates to:
  /// **'In Favorites'**
  String get inFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @freezeAccount.
  ///
  /// In en, this message translates to:
  /// **'Freeze Account'**
  String get freezeAccount;

  /// No description provided for @freezeAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to freeze your account?'**
  String get freezeAccountConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @messageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Message Notifications'**
  String get messageNotifications;

  /// No description provided for @offerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Offer Notifications'**
  String get offerNotifications;

  /// No description provided for @jobNotifications.
  ///
  /// In en, this message translates to:
  /// **'Job Listing Notifications'**
  String get jobNotifications;

  /// No description provided for @campaignNotifications.
  ///
  /// In en, this message translates to:
  /// **'Campaign Notifications'**
  String get campaignNotifications;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// No description provided for @screenshotTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Please select a screenshot smaller than 5 MB.'**
  String get screenshotTooLarge;

  /// No description provided for @selectSubject.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject.'**
  String get selectSubject;

  /// No description provided for @accountIssue.
  ///
  /// In en, this message translates to:
  /// **'Account Issue'**
  String get accountIssue;

  /// No description provided for @offerIssue.
  ///
  /// In en, this message translates to:
  /// **'Offer Issue'**
  String get offerIssue;

  /// No description provided for @chatIssue.
  ///
  /// In en, this message translates to:
  /// **'Chat Issue'**
  String get chatIssue;

  /// No description provided for @technicalIssue.
  ///
  /// In en, this message translates to:
  /// **'Technical Issue'**
  String get technicalIssue;

  /// No description provided for @complaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// No description provided for @accountSuspended.
  ///
  /// In en, this message translates to:
  /// **'My Account Was Suspended'**
  String get accountSuspended;

  /// No description provided for @appCrashes.
  ///
  /// In en, this message translates to:
  /// **'App Crashes'**
  String get appCrashes;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get howCanWeHelp;

  /// No description provided for @supportDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell us about the problem you are experiencing or your suggestion. Our support team will contact you by email as soon as possible.'**
  String get supportDescription;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required.'**
  String get descriptionRequired;

  /// No description provided for @descriptionTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please describe your problem in more detail.'**
  String get descriptionTooShort;

  /// No description provided for @screenshotOptional.
  ///
  /// In en, this message translates to:
  /// **'Screenshot (Optional)'**
  String get screenshotOptional;

  /// No description provided for @chooseScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Choose a screenshot from gallery'**
  String get chooseScreenshot;

  /// No description provided for @sendSupportRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Support Request'**
  String get sendSupportRequest;

  /// No description provided for @supportRequestCreated.
  ///
  /// In en, this message translates to:
  /// **'Support Request Created'**
  String get supportRequestCreated;

  /// No description provided for @supportRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Your support request has been sent successfully.\n\nOur support team will contact you via your email address as soon as possible.'**
  String get supportRequestSent;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorOccurred;

  /// No description provided for @supportRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Support request not found.'**
  String get supportRequestNotFound;

  /// No description provided for @supportRequest.
  ///
  /// In en, this message translates to:
  /// **'Support Request'**
  String get supportRequest;

  /// No description provided for @ticketNumber.
  ///
  /// In en, this message translates to:
  /// **'Ticket No.'**
  String get ticketNumber;

  /// No description provided for @supportTeam.
  ///
  /// In en, this message translates to:
  /// **'Support Team'**
  String get supportTeam;

  /// No description provided for @mySupportRequests.
  ///
  /// In en, this message translates to:
  /// **'My Support Requests'**
  String get mySupportRequests;

  /// No description provided for @noSupportRequests.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any support requests yet.'**
  String get noSupportRequests;

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @customerAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'You can create job listings and receive offers from craftsmen.'**
  String get customerAccountDescription;

  /// No description provided for @loggedInWithThisAccount.
  ///
  /// In en, this message translates to:
  /// **'You are logged in with this account'**
  String get loggedInWithThisAccount;

  /// No description provided for @switchToCustomerAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch to Customer Account'**
  String get switchToCustomerAccount;

  /// No description provided for @craftsmanAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'You can view job listings and submit offers.'**
  String get craftsmanAccountDescription;

  /// No description provided for @switchToCraftsmanAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch to Craftsman Account'**
  String get switchToCraftsmanAccount;

  /// No description provided for @enterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code.'**
  String get enterSixDigitCode;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired.'**
  String get codeExpired;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code.'**
  String get invalidCode;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent the verification code to\n{email}.'**
  String verificationCodeSent(Object email);

  /// No description provided for @checkSpamFolder.
  ///
  /// In en, this message translates to:
  /// **'If you cannot see the code, check your Spam/Junk folder.'**
  String get checkSpamFolder;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'VERIFY CODE'**
  String get verifyCode;

  /// No description provided for @requestNewCode.
  ///
  /// In en, this message translates to:
  /// **'You can request a new code.'**
  String get requestNewCode;

  /// No description provided for @newCodeInSeconds.
  ///
  /// In en, this message translates to:
  /// **'New code: {seconds}s'**
  String newCodeInSeconds(Object seconds);

  /// No description provided for @codeValiditySeconds.
  ///
  /// In en, this message translates to:
  /// **'Code validity period: {seconds}s'**
  String codeValiditySeconds(Object seconds);

  /// No description provided for @newVerificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent.'**
  String get newVerificationCodeSent;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'RESEND CODE'**
  String get resendCode;

  /// No description provided for @whatAreTokensFor.
  ///
  /// In en, this message translates to:
  /// **'⚡ What are Tokens used for?'**
  String get whatAreTokensFor;

  /// No description provided for @tokensUsedForOffers.
  ///
  /// In en, this message translates to:
  /// **'🪙 Tokens are only used to send offers.'**
  String get tokensUsedForOffers;

  /// No description provided for @tokensPerOffer.
  ///
  /// In en, this message translates to:
  /// **'50 Tokens are spent for each submitted offer.'**
  String get tokensPerOffer;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @tokenTransactions.
  ///
  /// In en, this message translates to:
  /// **'Token Transactions'**
  String get tokenTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noTransactionsYet;

  /// No description provided for @tokensPurchased.
  ///
  /// In en, this message translates to:
  /// **'Tokens Purchased'**
  String get tokensPurchased;

  /// No description provided for @bonusTokens.
  ///
  /// In en, this message translates to:
  /// **'Bonus Tokens'**
  String get bonusTokens;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @noBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'No blocked users.'**
  String get noBlockedUsers;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any chats yet.'**
  String get noChats;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @cannotMessageUser.
  ///
  /// In en, this message translates to:
  /// **'You cannot send messages to this user.'**
  String get cannotMessageUser;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @lastSeenToday.
  ///
  /// In en, this message translates to:
  /// **'Last seen today at {time}'**
  String lastSeenToday(Object time);

  /// No description provided for @lastSeenYesterday.
  ///
  /// In en, this message translates to:
  /// **'Last seen yesterday at {time}'**
  String lastSeenYesterday(Object time);

  /// No description provided for @lastSeenDate.
  ///
  /// In en, this message translates to:
  /// **'Last seen on {date}'**
  String lastSeenDate(Object date);

  /// No description provided for @favoriteAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} was added to favorites.'**
  String favoriteAdded(Object name);

  /// No description provided for @favoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} was removed from favorites.'**
  String favoriteRemoved(Object name);

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @clearChatConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear this chat?'**
  String get clearChatConfirmation;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared.'**
  String get chatCleared;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @deleteChatConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat?'**
  String get deleteChatConfirmation;

  /// No description provided for @chatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted.'**
  String get chatDeleted;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @blockConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block {name}?'**
  String blockConfirmation(Object name);

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'{name} has been blocked.'**
  String userBlocked(Object name);

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessages;

  /// No description provided for @cannotMessageBlockedUser.
  ///
  /// In en, this message translates to:
  /// **'You have blocked this user. You cannot send messages.'**
  String get cannotMessageBlockedUser;

  /// No description provided for @listingDetail.
  ///
  /// In en, this message translates to:
  /// **'Listing Details'**
  String get listingDetail;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @closedStatus.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedStatus;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications yet.'**
  String get noNotifications;

  /// No description provided for @newOffers.
  ///
  /// In en, this message translates to:
  /// **'There are no new offers yet.'**
  String get newOffers;

  /// No description provided for @offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offer;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @offerAccepted.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted.'**
  String get offerAccepted;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @incomingOffers.
  ///
  /// In en, this message translates to:
  /// **'Incoming Offers'**
  String get incomingOffers;

  /// No description provided for @noIncomingOffers.
  ///
  /// In en, this message translates to:
  /// **'No incoming offers yet.'**
  String get noIncomingOffers;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @craftsmanOffer.
  ///
  /// In en, this message translates to:
  /// **'Craftsman\'s Offer'**
  String get craftsmanOffer;

  /// No description provided for @offerPrice.
  ///
  /// In en, this message translates to:
  /// **'Offer Price'**
  String get offerPrice;

  /// No description provided for @offerAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Offer Was Accepted'**
  String get offerAcceptedTitle;

  /// No description provided for @offerAcceptedBody.
  ///
  /// In en, this message translates to:
  /// **'Your offer for the listing was accepted.'**
  String get offerAcceptedBody;

  /// No description provided for @offerRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Offer Was Rejected'**
  String get offerRejectedTitle;

  /// No description provided for @offerRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your offer for the listing was rejected.'**
  String get offerRejectedBody;

  /// No description provided for @offerAcceptedStatus.
  ///
  /// In en, this message translates to:
  /// **'This offer was accepted.'**
  String get offerAcceptedStatus;

  /// No description provided for @workingWithCraftsman.
  ///
  /// In en, this message translates to:
  /// **'I\'m Working With This Craftsman'**
  String get workingWithCraftsman;

  /// No description provided for @jobInProgressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Job status updated to in progress.'**
  String get jobInProgressUpdated;

  /// No description provided for @jobInProgress.
  ///
  /// In en, this message translates to:
  /// **'Job is in progress.'**
  String get jobInProgress;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @jobCompleted.
  ///
  /// In en, this message translates to:
  /// **'Job completed successfully.'**
  String get jobCompleted;

  /// No description provided for @jobCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'Job completed.'**
  String get jobCompletedStatus;

  /// No description provided for @reviewCraftsman.
  ///
  /// In en, this message translates to:
  /// **'Review Craftsman'**
  String get reviewCraftsman;

  /// No description provided for @craftsmanReviewed.
  ///
  /// In en, this message translates to:
  /// **'You reviewed this craftsman.'**
  String get craftsmanReviewed;

  /// No description provided for @offerRejectedStatus.
  ///
  /// In en, this message translates to:
  /// **'This offer was rejected.'**
  String get offerRejectedStatus;

  /// No description provided for @offerCancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'This offer was cancelled.'**
  String get offerCancelledStatus;

  /// No description provided for @craftsmanOffers.
  ///
  /// In en, this message translates to:
  /// **'My Offers'**
  String get craftsmanOffers;

  /// No description provided for @pendingOffers.
  ///
  /// In en, this message translates to:
  /// **'Pending Offers'**
  String get pendingOffers;

  /// No description provided for @acceptedOffers.
  ///
  /// In en, this message translates to:
  /// **'Accepted Offers'**
  String get acceptedOffers;

  /// No description provided for @rejectedOffers.
  ///
  /// In en, this message translates to:
  /// **'Rejected Offers'**
  String get rejectedOffers;

  /// No description provided for @inProgressOffers.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressOffers;

  /// No description provided for @completedOffers.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedOffers;

  /// No description provided for @ratingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How many stars would you give?'**
  String get ratingQuestion;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write your comment...'**
  String get writeComment;

  /// No description provided for @reviewSaved.
  ///
  /// In en, this message translates to:
  /// **'Your review has been saved.'**
  String get reviewSaved;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get switchAccount;

  /// No description provided for @job.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get job;

  /// No description provided for @listing.
  ///
  /// In en, this message translates to:
  /// **'Listing'**
  String get listing;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @profession.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get profession;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @noAboutInfo.
  ///
  /// In en, this message translates to:
  /// **'No information has been added yet.'**
  String get noAboutInfo;

  /// No description provided for @tokenStore.
  ///
  /// In en, this message translates to:
  /// **'Token Store'**
  String get tokenStore;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get purchase;

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google Play is unavailable.'**
  String get storeUnavailable;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'This product was not found on Google Play.'**
  String get productNotFound;

  /// No description provided for @purchaseStartFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be started.'**
  String get purchaseStartFailed;

  /// No description provided for @purchasePending.
  ///
  /// In en, this message translates to:
  /// **'Purchase pending.'**
  String get purchasePending;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase failed.'**
  String get purchaseFailed;

  /// No description provided for @purchaseVerificationInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'Purchase verification information was not found.'**
  String get purchaseVerificationInfoMissing;

  /// No description provided for @purchaseNotVerified.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be verified.'**
  String get purchaseNotVerified;

  /// No description provided for @purchaseAlreadyProcessed.
  ///
  /// In en, this message translates to:
  /// **'This purchase has already been processed.'**
  String get purchaseAlreadyProcessed;

  /// No description provided for @tokensAdded.
  ///
  /// In en, this message translates to:
  /// **'{tokens} tokens have been added to your account.'**
  String tokensAdded(Object tokens);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
