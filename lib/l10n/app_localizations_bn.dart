// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get dashboardTitle => 'ড্যাশবোর্ড';

  @override
  String get bookingsTitle => 'বুকিং';

  @override
  String get transactionsTitle => 'লেনদেন';

  @override
  String welcomeBack(String userName) {
    return 'স্বাগতম, $userName!';
  }

  @override
  String get upcomingBookings => 'আসন্ন বুকিং';

  @override
  String get outstandingDues => 'মোট বকেয়া';

  @override
  String get bookingsThisMonth => 'এই মাসের বুকিং';

  @override
  String get revenueThisMonth => 'এই মাসের মোট আয়';

  @override
  String get totalOwed => 'মোট পাওনা';

  @override
  String get menuTitle => 'মেনু ও সেটিংস';

  @override
  String get financialManagement => 'আর্থিক ব্যবস্থাপনা';

  @override
  String get otherIncome => 'অন্যান্য আয়';

  @override
  String get expenses => 'খরচ';

  @override
  String get hrAndSalaries => 'মানবসম্পদ ও বেতন';

  @override
  String get manageSalaries => 'বেতন পরিচালনা';

  @override
  String get manageWorkers => 'কর্মী পরিচালনা';

  @override
  String get liabilities => 'দায়';

  @override
  String get borrowedFunds => 'ধার করা তহবিল';

  @override
  String get manageLenders => 'ঋণদাতা পরিচালনা';

  @override
  String get language => 'ভাষা';

  @override
  String get changeLanguage => 'ভাষা পরিবর্তন করুন';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get myPermissions => 'আমার অনুমতি';

  @override
  String get noPermissionsFound => 'কোনো নির্দিষ্ট অনুমতি পাওয়া যায়নি।';

  @override
  String get logout => 'লগ আউট';

  @override
  String get confirmLogout => 'লগ আউট নিশ্চিত করুন';

  @override
  String get areYouSureLogout => 'আপনি কি লগ আউট করতে নিশ্চিত?';

  @override
  String get cancel => 'বাতিল';

  @override
  String get createNewBooking => 'নতুন বুকিং তৈরি করুন';

  @override
  String get saveBooking => 'বুকিং চুক্তি সংরক্ষণ করুন';

  @override
  String get customerDetails => 'গ্রাহকের বিবরণ';

  @override
  String get customerName => 'গ্রাহকের নাম';

  @override
  String get customerPhone => 'গ্রাহকের ফোন';

  @override
  String get address => 'ঠিকানা';

  @override
  String get eventDetails => 'ইভেন্টের বিবরণ';

  @override
  String get eventType => 'ইভেন্টের ধরন';

  @override
  String get manualReceiptNo => 'ম্যানুয়াল রসিদ নং (ঐচ্ছিক)';

  @override
  String get guests => 'অতিথি';

  @override
  String get tables => 'টেবিল';

  @override
  String get servers => 'সার্ভার';

  @override
  String get bookingDates => 'বুকিংয়ের তারিখ';

  @override
  String get financials => 'আর্থিক বিবরণ';

  @override
  String get totalAmount => 'মোট পরিমাণ';

  @override
  String get advanceAmount => 'অগ্রিম পরিমাণ';

  @override
  String get inWords => 'কথায়';

  @override
  String get inWordsHint => 'খালি রাখলে স্বয়ংক্রিয়ভাবে তৈরি হবে';

  @override
  String get requiredField => 'আবশ্যক';

  @override
  String get addDate => 'তারিখ যোগ করুন';

  @override
  String get eventDate => 'ইভেন্টের তারিখ';

  @override
  String get timeSlot => 'সময়';

  @override
  String get addedDates => 'যোগ করা তারিখ';

  @override
  String get pleaseAddDate => 'অনুগ্রহ করে কমপক্ষে একটি বুকিং তারিখ যোগ করুন।';

  @override
  String get pleaseSelectDate => 'অনুগ্রহ করে প্রথমে একটি তারিখ নির্বাচন করুন।';

  @override
  String get bookingCreatedSuccess => 'বুকিং সফলভাবে তৈরি করা হয়েছে!';

  @override
  String get bookingFailed => 'বুকিং তৈরি করতে ব্যর্থ হয়েছে।';

  @override
  String get removeDate => 'তারিখ মুছুন';
}
