// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get orgName => 'মমতা কমিউনিটি সেন্টার';

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
  String get phone => 'মোবাইল নম্বর';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get eventTypeWedding => 'বিয়ে';

  @override
  String get eventTypeGayeHolud => 'গায়ে হলুদ';

  @override
  String get eventTypeBirthday => 'জন্মদিন';

  @override
  String get eventTypeAqiqah => 'আকিকা';

  @override
  String get eventTypeMezban => 'মেজবান';

  @override
  String get eventTypeSeminar => 'সেমিনার';

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
  String get slotDay => 'দিন';

  @override
  String get slotNight => 'রাত';

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

  @override
  String get bookingDetailsTitle => 'বুকিং বিবরণ';

  @override
  String get addPayment => 'পেমেন্ট যোগ করুন';

  @override
  String get failedToLoadBooking => 'বুকিং বিবরণ লোড করতে ব্যর্থ হয়েছে।';

  @override
  String get totalPaid => 'মোট পরিশোধিত';

  @override
  String get amountDue => 'বকেয়া পরিমাণ';

  @override
  String get bookingInformation => 'বুকিং তথ্য';

  @override
  String get scheduledDates => 'নির্ধারিত তারিখ';

  @override
  String get paymentHistory => 'পেমেন্টের ইতিহাস';

  @override
  String get noDatesScheduled => 'কোনো তারিখ নির্ধারিত নেই।';

  @override
  String get noPaymentsRecorded => 'এখনো কোনো পেমেন্ট রেকর্ড করা হয়নি।';

  @override
  String get amountToPay => 'প্রদেয় পরিমাণ';

  @override
  String get paymentDate => 'পেমেন্টের তারিখ';

  @override
  String get paymentMethod => 'পেমেন্ট পদ্ধতি';

  @override
  String get notesOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get submit => 'জমা দিন';

  @override
  String get paymentAddedSuccess => 'পেমেন্ট সফলভাবে যোগ করা হয়েছে!';

  @override
  String get paymentFailed =>
      'পেমেন্ট যোগ করতে ব্যর্থ হয়েছে। ইনপুট পরীক্ষা করুন।';

  @override
  String get paymentMethodCash => 'নগদ';

  @override
  String get paymentMethodBank => 'ব্যাংক স্থানান্তর';

  @override
  String get paymentMethodMobile => 'মোবাইল ব্যাংকিং';

  @override
  String get editIncome => 'আয় সম্পাদনা করুন';

  @override
  String get logNewIncome => 'নতুন আয় লগ করুন';

  @override
  String get category => 'বিভাগ';

  @override
  String get pleaseSelectCategory => 'অনুগ্রহ করে একটি বিভাগ নির্বাচন করুন';

  @override
  String get amount => 'পরিমাণ';

  @override
  String get pleaseEnterAmount => 'অনুগ্রহ করে একটি পরিমাণ লিখুন';

  @override
  String get date => 'তারিখ';

  @override
  String get descriptionOptional => 'বিবরণ (ঐচ্ছিক)';

  @override
  String get updateIncome => 'আয় আপডেট করুন';

  @override
  String get saveIncome => 'আয় সংরক্ষণ করুন';

  @override
  String get incomeUpdatedSuccess => 'আয় সফলভাবে আপডেট করা হয়েছে!';

  @override
  String get incomeLoggedSuccess => 'আয় সফলভাবে লগ করা হয়েছে!';

  @override
  String get failedToUpdateIncome => 'আয় আপডেট করতে ব্যর্থ হয়েছে।';

  @override
  String get failedToLogIncome => 'আয় লগ করতে ব্যর্থ হয়েছে।';

  @override
  String get allIncomes => 'অন্যান্য সকল আয়';

  @override
  String get filterIncomes => 'আয় ফিল্টার করুন';

  @override
  String get logIncome => 'আয় লগ করুন';

  @override
  String get noIncomesFound =>
      'নির্বাচিত ফিল্টারের জন্য কোনো আয় রেকর্ড পাওয়া যায়নি।';

  @override
  String get confirmDelete => 'মুছে ফেলা নিশ্চিত করুন';

  @override
  String get areYouSureDeleteIncome =>
      'আপনি কি এই আয় রেকর্ডটি মুছে ফেলতে নিশ্চিত?';

  @override
  String get incomeDeleted => 'আয় রেকর্ড মুছে ফেলা হয়েছে';

  @override
  String get failedToDeleteIncome => 'আয় মুছে ফেলতে ব্যর্থ হয়েছে';

  @override
  String get delete => 'মুছুন';

  @override
  String get filters => 'ফিল্টার:';

  @override
  String get clearFilters => 'ফিল্টার সাফ করুন';

  @override
  String get loadMore => 'আরও লোড করুন';

  @override
  String get filterOptions => 'ফিল্টার বিকল্প';

  @override
  String get selectDateRange => 'তারিখ সীমা নির্বাচন করুন';

  @override
  String get applyFilters => 'ফিল্টার প্রয়োগ করুন';

  @override
  String get editExpense => 'খরচ সম্পাদনা করুন';

  @override
  String get logNewExpense => 'নতুন খরচ লগ করুন';

  @override
  String get updateExpense => 'খরচ আপডেট করুন';

  @override
  String get saveExpense => 'খরচ সংরক্ষণ করুন';

  @override
  String get expenseUpdatedSuccess => 'খরচ সফলভাবে আপডেট করা হয়েছে!';

  @override
  String get expenseLoggedSuccess => 'খরচ সফলভাবে লগ করা হয়েছে!';

  @override
  String get failedToUpdateExpense => 'খরচ আপডেট করতে ব্যর্থ হয়েছে।';

  @override
  String get failedToLogExpense => 'খরচ লগ করতে ব্যর্থ হয়েছে।';

  @override
  String get allExpenses => 'সকল খরচ';

  @override
  String get filterExpenses => 'খরচ ফিল্টার করুন';

  @override
  String get logExpense => 'খরচ লগ করুন';

  @override
  String get noExpensesFound =>
      'নির্বাচিত ফিল্টারের জন্য কোনো খরচ পাওয়া যায়নি।';

  @override
  String get areYouSureDeleteExpense => 'আপনি কি এই খরচটি মুছে ফেলতে নিশ্চিত?';

  @override
  String get expenseDeleted => 'খরচ মুছে ফেলা হয়েছে';

  @override
  String get failedToDeleteExpense => 'খরচ মুছে ফেলতে ব্যর্থ হয়েছে';

  @override
  String get noDescription => 'কোনো বিবরণ নেই';

  @override
  String get salaryDetails => 'বেতনের বিবরণ';

  @override
  String get recordPayment => 'পেমেন্ট রেকর্ড করুন';

  @override
  String get failedToLoadSalary => 'বেতনের বিবরণ লোড করতে ব্যর্থ হয়েছে।';

  @override
  String get totalSalary => 'মোট বেতন';

  @override
  String get salaryInformation => 'বেতনের তথ্য';

  @override
  String get worker => 'কর্মী:';

  @override
  String get salaryFor => 'যে মাসের বেতন:';

  @override
  String get status => 'স্ট্যাটাস:';

  @override
  String get noPaymentsThisMonth =>
      'এই মাসের জন্য কোনো পেমেন্ট রেকর্ড করা হয়নি।';

  @override
  String get paymentRecordedSuccess => 'পেমেন্ট সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get failedToRecordPayment => 'পেমেন্ট রেকর্ড করতে ব্যর্থ হয়েছে।';

  @override
  String get generateSalaries => 'মাসের জন্য বেতন তৈরি করুন';

  @override
  String get selectMonthAndYear => 'তৈরি করার জন্য মাস এবং বছর নির্বাচন করুন';

  @override
  String salariesGeneratedSuccess(Object monthYear) {
    return '$monthYear মাসের জন্য বেতন সফলভাবে তৈরি করা হয়েছে!';
  }

  @override
  String get failedToGenerateSalaries => 'বেতন তৈরি করতে ব্যর্থ হয়েছে।';

  @override
  String get noSalaryRecordsFound =>
      'কোনো বেতন রেকর্ড পাওয়া যায়নি।\nএকটি মাসের জন্য তৈরি করার চেষ্টা করুন।';

  @override
  String get statusPaid => 'পরিশোধিত';

  @override
  String get statusPending => 'বকেয়া';

  @override
  String get statusPartiallyPaid => 'আংশিক পরিশোধিত';

  @override
  String get statusUnpaid => 'অপরিশোধিত';

  @override
  String get filterFunds => 'তহবিল ফিল্টার করুন';

  @override
  String get recordBorrowedFund => 'ধার করা তহবিল রেকর্ড করুন';

  @override
  String get noFundsFound =>
      'নির্বাচিত ফিল্টারের জন্য কোনো ধার করা তহবিল পাওয়া যায়নি।';

  @override
  String get from => 'থেকে:';

  @override
  String get on => '-তে';

  @override
  String get lenderSource => 'ঋণদাতা/উৎস';

  @override
  String get statusRepaid => 'পরিশোধিত';

  @override
  String get statusPartiallyRepaid => 'আংশিক পরিশোধিত';

  @override
  String get statusDue => 'বকেয়া';

  @override
  String get manageRepayments => 'পরিশোধ পরিচালনা';

  @override
  String get recordRepayment => 'পরিশোধ রেকর্ড করুন';

  @override
  String get failedToLoadDetails => 'বিবরণ লোড করতে ব্যর্থ হয়েছে।';

  @override
  String get totalBorrowed => 'মোট ধার';

  @override
  String get totalRepaid => 'মোট পরিশোধিত';

  @override
  String get loanInformation => 'ঋণের তথ্য';

  @override
  String get purpose => 'উদ্দেশ্য:';

  @override
  String get dateBorrowed => 'ধারের তারিখ:';

  @override
  String get repaymentHistory => 'পরিশোধের ইতিহাস';

  @override
  String get noRepaymentsRecorded =>
      'এই ঋণের জন্য কোনো পরিশোধ রেকর্ড করা হয়নি।';

  @override
  String get repaymentRecordedSuccess => 'পরিশোধ সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get failedToRecordRepayment => 'পরিশোধ রেকর্ড করতে ব্যর্থ হয়েছে।';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get pleaseSelectLender => 'অনুগ্রহ করে একজন ঋণদাতা/উৎস নির্বাচন করুন';

  @override
  String get amountBorrowed => 'ধার করা পরিমাণ';

  @override
  String get pleaseEnterPurpose => 'অনুগ্রহ করে একটি উদ্দেশ্য লিখুন';

  @override
  String get saveRecord => 'রেকর্ড সংরক্ষণ করুন';

  @override
  String get fundRecordCreatedSuccess =>
      'তহবিল রেকর্ড সফলভাবে তৈরি করা হয়েছে!';

  @override
  String get failedToCreateRecord => 'রেকর্ড তৈরি করতে ব্যর্থ হয়েছে।';

  @override
  String get stayLoggedIn => 'লগইন থাকুন';

  @override
  String get login => 'লগইন করুন';

  @override
  String get welcomeToLogin => 'স্বাগতম! চালিয়ে যেতে সাইন ইন করুন।';

  @override
  String get newBooking => 'নতুন বুকিং';

  @override
  String get filterByDate => 'তারিখের সীমা দ্বারা ফিল্টার করুন';

  @override
  String get searchByHint => 'নাম, ফোন, ইভেন্ট দ্বারা অনুসন্ধান...';

  @override
  String get noBookingsFoundFilters =>
      'নির্বাচিত ফিল্টারের জন্য কোনো বুকিং পাওয়া যায়নি।';

  @override
  String get areYouSureDeleteBooking =>
      'আপনি কি এই বুকিংটি মুছে ফেলতে নিশ্চিত?';

  @override
  String get bookingDeleted => 'বুকিং মুছে ফেলা হয়েছে';

  @override
  String get failedToDeleteBooking => 'বুকিং মুছতে ব্যর্থ হয়েছে';

  @override
  String get financialSummary => 'আর্থিক সারসংক্ষেপ';

  @override
  String get generateReport => 'রিপোর্ট তৈরি করুন';

  @override
  String get openingBalance => 'প্রারম্ভিক ব্যালেন্স';

  @override
  String get closingBalance => 'সমাপনী ব্যালেন্স';

  @override
  String get totalIncomePeriod => 'মোট আয় (সময়কাল)';

  @override
  String get totalExpensesPeriod => 'মোট খরচ (সময়কাল)';

  @override
  String get incomeCredits => 'আয় / ক্রেডিট';

  @override
  String get expensesDebits => 'খরচ / ডেবিট';

  @override
  String get netCashFlow => 'সময়কালের জন্য নেট ক্যাশ ফ্লো';

  @override
  String get bookingPayments => 'বুকিং পেমেন্ট';

  @override
  String get generalExpenses => 'সাধারণ খরচ';

  @override
  String get salaryPayments => 'বেতন প্রদান';

  @override
  String get loanRepayments => 'ঋণ পরিশোধ';

  @override
  String get period => 'সময়কাল:';

  @override
  String get totalIncome => 'মোট আয়';

  @override
  String get totalExpenses => 'মোট খরচ';

  @override
  String get bookingCalendar => 'বুকিং ক্যালেন্ডার';

  @override
  String get noBookingsForDay => 'এই দিনে কোনো বুকিং নেই।';

  @override
  String get dueAmount => 'বকেয়া পরিমাণ';
}
