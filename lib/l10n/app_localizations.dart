import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @orgName.
  ///
  /// In en, this message translates to:
  /// **'Momota Community Center'**
  String get orgName;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookingsTitle;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// A welcome message on the dashboard
  ///
  /// In en, this message translates to:
  /// **'Welcome Back, {userName}!'**
  String welcomeBack(String userName);

  /// No description provided for @upcomingBookings.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Bookings'**
  String get upcomingBookings;

  /// No description provided for @outstandingDues.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Dues'**
  String get outstandingDues;

  /// No description provided for @bookingsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Bookings This Month'**
  String get bookingsThisMonth;

  /// No description provided for @revenueThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue This Month'**
  String get revenueThisMonth;

  /// No description provided for @totalOwed.
  ///
  /// In en, this message translates to:
  /// **'Total Owed'**
  String get totalOwed;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu & Settings'**
  String get menuTitle;

  /// No description provided for @financialManagement.
  ///
  /// In en, this message translates to:
  /// **'Financial Management'**
  String get financialManagement;

  /// No description provided for @otherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get otherIncome;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @hrAndSalaries.
  ///
  /// In en, this message translates to:
  /// **'HR & Salaries'**
  String get hrAndSalaries;

  /// No description provided for @manageSalaries.
  ///
  /// In en, this message translates to:
  /// **'Manage Salaries'**
  String get manageSalaries;

  /// No description provided for @manageWorkers.
  ///
  /// In en, this message translates to:
  /// **'Manage Workers'**
  String get manageWorkers;

  /// No description provided for @liabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get liabilities;

  /// No description provided for @borrowedFunds.
  ///
  /// In en, this message translates to:
  /// **'Borrowed Funds'**
  String get borrowedFunds;

  /// No description provided for @manageLenders.
  ///
  /// In en, this message translates to:
  /// **'Manage Lenders'**
  String get manageLenders;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @myPermissions.
  ///
  /// In en, this message translates to:
  /// **'My Permissions'**
  String get myPermissions;

  /// No description provided for @noPermissionsFound.
  ///
  /// In en, this message translates to:
  /// **'No specific permissions found.'**
  String get noPermissionsFound;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @eventTypeWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get eventTypeWedding;

  /// No description provided for @eventTypeGayeHolud.
  ///
  /// In en, this message translates to:
  /// **'Gaye Holud'**
  String get eventTypeGayeHolud;

  /// No description provided for @eventTypeBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get eventTypeBirthday;

  /// No description provided for @eventTypeAqiqah.
  ///
  /// In en, this message translates to:
  /// **'Aqiqah'**
  String get eventTypeAqiqah;

  /// No description provided for @eventTypeMezban.
  ///
  /// In en, this message translates to:
  /// **'Mezban'**
  String get eventTypeMezban;

  /// No description provided for @eventTypeSeminar.
  ///
  /// In en, this message translates to:
  /// **'Seminar'**
  String get eventTypeSeminar;

  /// No description provided for @createNewBooking.
  ///
  /// In en, this message translates to:
  /// **'Create New Booking'**
  String get createNewBooking;

  /// No description provided for @saveBooking.
  ///
  /// In en, this message translates to:
  /// **'Save Booking Contract'**
  String get saveBooking;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @customerPhone.
  ///
  /// In en, this message translates to:
  /// **'Customer Phone'**
  String get customerPhone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetails;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @manualReceiptNo.
  ///
  /// In en, this message translates to:
  /// **'Manual Receipt No (Optional)'**
  String get manualReceiptNo;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @tables.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get tables;

  /// No description provided for @servers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get servers;

  /// No description provided for @bookingDates.
  ///
  /// In en, this message translates to:
  /// **'Booking Dates'**
  String get bookingDates;

  /// No description provided for @financials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get financials;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @advanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Advance Amount'**
  String get advanceAmount;

  /// No description provided for @inWords.
  ///
  /// In en, this message translates to:
  /// **'In Words'**
  String get inWords;

  /// No description provided for @inWordsHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-generated if blank'**
  String get inWordsHint;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @addDate.
  ///
  /// In en, this message translates to:
  /// **'Add Date'**
  String get addDate;

  /// No description provided for @eventDate.
  ///
  /// In en, this message translates to:
  /// **'Event Date'**
  String get eventDate;

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get timeSlot;

  /// No description provided for @slotDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get slotDay;

  /// No description provided for @slotNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get slotNight;

  /// No description provided for @addedDates.
  ///
  /// In en, this message translates to:
  /// **'Added Dates'**
  String get addedDates;

  /// No description provided for @pleaseAddDate.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one booking date.'**
  String get pleaseAddDate;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date first.'**
  String get pleaseSelectDate;

  /// No description provided for @bookingCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking created successfully!'**
  String get bookingCreatedSuccess;

  /// No description provided for @bookingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create booking.'**
  String get bookingFailed;

  /// No description provided for @removeDate.
  ///
  /// In en, this message translates to:
  /// **'Remove Date'**
  String get removeDate;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetailsTitle;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @failedToLoadBooking.
  ///
  /// In en, this message translates to:
  /// **'Failed to load booking details.'**
  String get failedToLoadBooking;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @amountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get amountDue;

  /// No description provided for @bookingInformation.
  ///
  /// In en, this message translates to:
  /// **'Booking Information'**
  String get bookingInformation;

  /// No description provided for @scheduledDates.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Dates'**
  String get scheduledDates;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @noDatesScheduled.
  ///
  /// In en, this message translates to:
  /// **'No dates scheduled.'**
  String get noDatesScheduled;

  /// No description provided for @noPaymentsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get noPaymentsRecorded;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get amountToPay;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @paymentAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment added successfully!'**
  String get paymentAddedSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add payment. Check input.'**
  String get paymentFailed;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentMethodBank;

  /// No description provided for @paymentMethodMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Banking'**
  String get paymentMethodMobile;

  /// No description provided for @editIncome.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncome;

  /// No description provided for @logNewIncome.
  ///
  /// In en, this message translates to:
  /// **'Log New Income'**
  String get logNewIncome;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @updateIncome.
  ///
  /// In en, this message translates to:
  /// **'Update Income'**
  String get updateIncome;

  /// No description provided for @saveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save Income'**
  String get saveIncome;

  /// No description provided for @incomeUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Income updated successfully!'**
  String get incomeUpdatedSuccess;

  /// No description provided for @incomeLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Income logged successfully!'**
  String get incomeLoggedSuccess;

  /// No description provided for @failedToUpdateIncome.
  ///
  /// In en, this message translates to:
  /// **'Failed to update income.'**
  String get failedToUpdateIncome;

  /// No description provided for @failedToLogIncome.
  ///
  /// In en, this message translates to:
  /// **'Failed to log income.'**
  String get failedToLogIncome;

  /// No description provided for @allIncomes.
  ///
  /// In en, this message translates to:
  /// **'All Other Income'**
  String get allIncomes;

  /// No description provided for @filterIncomes.
  ///
  /// In en, this message translates to:
  /// **'Filter Incomes'**
  String get filterIncomes;

  /// No description provided for @logIncome.
  ///
  /// In en, this message translates to:
  /// **'Log Income'**
  String get logIncome;

  /// No description provided for @noIncomesFound.
  ///
  /// In en, this message translates to:
  /// **'No income records found for the selected filters.'**
  String get noIncomesFound;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @areYouSureDeleteIncome.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you wish to delete this income record?'**
  String get areYouSureDeleteIncome;

  /// No description provided for @incomeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Income record deleted'**
  String get incomeDeleted;

  /// No description provided for @failedToDeleteIncome.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete income'**
  String get failedToDeleteIncome;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters:'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @logNewExpense.
  ///
  /// In en, this message translates to:
  /// **'Log New Expense'**
  String get logNewExpense;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @expenseUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully!'**
  String get expenseUpdatedSuccess;

  /// No description provided for @expenseLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Expense logged successfully!'**
  String get expenseLoggedSuccess;

  /// No description provided for @failedToUpdateExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to update expense.'**
  String get failedToUpdateExpense;

  /// No description provided for @failedToLogExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to log expense.'**
  String get failedToLogExpense;

  /// No description provided for @allExpenses.
  ///
  /// In en, this message translates to:
  /// **'All Expenses'**
  String get allExpenses;

  /// No description provided for @filterExpenses.
  ///
  /// In en, this message translates to:
  /// **'Filter Expenses'**
  String get filterExpenses;

  /// No description provided for @logExpense.
  ///
  /// In en, this message translates to:
  /// **'Log Expense'**
  String get logExpense;

  /// No description provided for @noExpensesFound.
  ///
  /// In en, this message translates to:
  /// **'No expenses found for the selected filters.'**
  String get noExpensesFound;

  /// No description provided for @areYouSureDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you wish to delete this expense?'**
  String get areYouSureDeleteExpense;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @failedToDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete expense'**
  String get failedToDeleteExpense;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @salaryDetails.
  ///
  /// In en, this message translates to:
  /// **'Salary Details'**
  String get salaryDetails;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @failedToLoadSalary.
  ///
  /// In en, this message translates to:
  /// **'Failed to load salary details.'**
  String get failedToLoadSalary;

  /// No description provided for @totalSalary.
  ///
  /// In en, this message translates to:
  /// **'Total Salary'**
  String get totalSalary;

  /// No description provided for @salaryInformation.
  ///
  /// In en, this message translates to:
  /// **'Salary Information'**
  String get salaryInformation;

  /// No description provided for @worker.
  ///
  /// In en, this message translates to:
  /// **'Worker:'**
  String get worker;

  /// No description provided for @salaryFor.
  ///
  /// In en, this message translates to:
  /// **'Salary For:'**
  String get salaryFor;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get status;

  /// No description provided for @noPaymentsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded for this month.'**
  String get noPaymentsThisMonth;

  /// No description provided for @paymentRecordedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded successfully!'**
  String get paymentRecordedSuccess;

  /// No description provided for @failedToRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Failed to record payment.'**
  String get failedToRecordPayment;

  /// No description provided for @generateSalaries.
  ///
  /// In en, this message translates to:
  /// **'Generate Salaries for a Month'**
  String get generateSalaries;

  /// No description provided for @selectMonthAndYear.
  ///
  /// In en, this message translates to:
  /// **'Select Month and Year to Generate'**
  String get selectMonthAndYear;

  /// No description provided for @salariesGeneratedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Salaries for {monthYear} generated successfully!'**
  String salariesGeneratedSuccess(Object monthYear);

  /// No description provided for @failedToGenerateSalaries.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate salaries.'**
  String get failedToGenerateSalaries;

  /// No description provided for @noSalaryRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No salary records found.\nTry generating for a month.'**
  String get noSalaryRecordsFound;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusPartiallyPaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Paid'**
  String get statusPartiallyPaid;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @filterFunds.
  ///
  /// In en, this message translates to:
  /// **'Filter Funds'**
  String get filterFunds;

  /// No description provided for @recordBorrowedFund.
  ///
  /// In en, this message translates to:
  /// **'Record Borrowed Fund'**
  String get recordBorrowedFund;

  /// No description provided for @noFundsFound.
  ///
  /// In en, this message translates to:
  /// **'No borrowed funds found for the selected filters.'**
  String get noFundsFound;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get from;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @lenderSource.
  ///
  /// In en, this message translates to:
  /// **'Lender/Source'**
  String get lenderSource;

  /// No description provided for @statusRepaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get statusRepaid;

  /// No description provided for @statusPartiallyRepaid.
  ///
  /// In en, this message translates to:
  /// **'Partially Repaid'**
  String get statusPartiallyRepaid;

  /// No description provided for @statusDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get statusDue;

  /// No description provided for @manageRepayments.
  ///
  /// In en, this message translates to:
  /// **'Manage Repayments'**
  String get manageRepayments;

  /// No description provided for @recordRepayment.
  ///
  /// In en, this message translates to:
  /// **'Record Repayment'**
  String get recordRepayment;

  /// No description provided for @failedToLoadDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load details.'**
  String get failedToLoadDetails;

  /// No description provided for @totalBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Total Borrowed'**
  String get totalBorrowed;

  /// No description provided for @totalRepaid.
  ///
  /// In en, this message translates to:
  /// **'Total Repaid'**
  String get totalRepaid;

  /// No description provided for @loanInformation.
  ///
  /// In en, this message translates to:
  /// **'Loan Information'**
  String get loanInformation;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose:'**
  String get purpose;

  /// No description provided for @dateBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Date Borrowed:'**
  String get dateBorrowed;

  /// No description provided for @repaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Repayment History'**
  String get repaymentHistory;

  /// No description provided for @noRepaymentsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No repayments recorded for this loan.'**
  String get noRepaymentsRecorded;

  /// No description provided for @repaymentRecordedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Repayment recorded successfully!'**
  String get repaymentRecordedSuccess;

  /// No description provided for @failedToRecordRepayment.
  ///
  /// In en, this message translates to:
  /// **'Failed to record repayment.'**
  String get failedToRecordRepayment;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @pleaseSelectLender.
  ///
  /// In en, this message translates to:
  /// **'Please select a lender/source'**
  String get pleaseSelectLender;

  /// No description provided for @amountBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Amount Borrowed'**
  String get amountBorrowed;

  /// No description provided for @pleaseEnterPurpose.
  ///
  /// In en, this message translates to:
  /// **'Please enter a purpose'**
  String get pleaseEnterPurpose;

  /// No description provided for @saveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get saveRecord;

  /// No description provided for @fundRecordCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Fund record created successfully!'**
  String get fundRecordCreatedSuccess;

  /// No description provided for @failedToCreateRecord.
  ///
  /// In en, this message translates to:
  /// **'Failed to create record.'**
  String get failedToCreateRecord;

  /// No description provided for @stayLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Stay Logged In'**
  String get stayLoggedIn;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @welcomeToLogin.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back! Sign in to continue.'**
  String get welcomeToLogin;

  /// No description provided for @newBooking.
  ///
  /// In en, this message translates to:
  /// **'New Booking'**
  String get newBooking;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date Range'**
  String get filterByDate;

  /// No description provided for @searchByHint.
  ///
  /// In en, this message translates to:
  /// **'Search by Name, Phone, Event...'**
  String get searchByHint;

  /// No description provided for @noBookingsFoundFilters.
  ///
  /// In en, this message translates to:
  /// **'No bookings found for the selected filters.'**
  String get noBookingsFoundFilters;

  /// No description provided for @areYouSureDeleteBooking.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you wish to delete this booking?'**
  String get areYouSureDeleteBooking;

  /// No description provided for @bookingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Booking deleted'**
  String get bookingDeleted;

  /// No description provided for @failedToDeleteBooking.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete booking'**
  String get failedToDeleteBooking;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalance;

  /// No description provided for @closingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing Balance'**
  String get closingBalance;

  /// No description provided for @totalIncomePeriod.
  ///
  /// In en, this message translates to:
  /// **'Total Income (Period)'**
  String get totalIncomePeriod;

  /// No description provided for @totalExpensesPeriod.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses (Period)'**
  String get totalExpensesPeriod;

  /// No description provided for @incomeCredits.
  ///
  /// In en, this message translates to:
  /// **'Income / Credits'**
  String get incomeCredits;

  /// No description provided for @expensesDebits.
  ///
  /// In en, this message translates to:
  /// **'Expenses / Debits'**
  String get expensesDebits;

  /// No description provided for @netCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Net Cash Flow for the Period'**
  String get netCashFlow;

  /// No description provided for @bookingPayments.
  ///
  /// In en, this message translates to:
  /// **'Booking Payments'**
  String get bookingPayments;

  /// No description provided for @generalExpenses.
  ///
  /// In en, this message translates to:
  /// **'General Expenses'**
  String get generalExpenses;

  /// No description provided for @salaryPayments.
  ///
  /// In en, this message translates to:
  /// **'Salary Payments'**
  String get salaryPayments;

  /// No description provided for @loanRepayments.
  ///
  /// In en, this message translates to:
  /// **'Loan Repayments'**
  String get loanRepayments;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period:'**
  String get period;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @bookingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Booking Calendar'**
  String get bookingCalendar;

  /// No description provided for @noBookingsForDay.
  ///
  /// In en, this message translates to:
  /// **'No bookings for this day.'**
  String get noBookingsForDay;

  /// No description provided for @dueAmount.
  ///
  /// In en, this message translates to:
  /// **'Due Amount'**
  String get dueAmount;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
