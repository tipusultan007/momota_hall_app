// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get bookingsTitle => 'Bookings';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String welcomeBack(String userName) {
    return 'Welcome Back, $userName!';
  }

  @override
  String get upcomingBookings => 'Upcoming Bookings';

  @override
  String get outstandingDues => 'Outstanding Dues';

  @override
  String get bookingsThisMonth => 'Bookings This Month';

  @override
  String get revenueThisMonth => 'Total Revenue This Month';

  @override
  String get totalOwed => 'Total Owed';

  @override
  String get menuTitle => 'Menu & Settings';

  @override
  String get financialManagement => 'Financial Management';

  @override
  String get otherIncome => 'Other Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get hrAndSalaries => 'HR & Salaries';

  @override
  String get manageSalaries => 'Manage Salaries';

  @override
  String get manageWorkers => 'Manage Workers';

  @override
  String get liabilities => 'Liabilities';

  @override
  String get borrowedFunds => 'Borrowed Funds';

  @override
  String get manageLenders => 'Manage Lenders';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get account => 'Account';

  @override
  String get myPermissions => 'My Permissions';

  @override
  String get noPermissionsFound => 'No specific permissions found.';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get areYouSureLogout => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get createNewBooking => 'Create New Booking';

  @override
  String get saveBooking => 'Save Booking Contract';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerPhone => 'Customer Phone';

  @override
  String get address => 'Address';

  @override
  String get eventDetails => 'Event Details';

  @override
  String get eventType => 'Event Type';

  @override
  String get manualReceiptNo => 'Manual Receipt No (Optional)';

  @override
  String get guests => 'Guests';

  @override
  String get tables => 'Tables';

  @override
  String get servers => 'Servers';

  @override
  String get bookingDates => 'Booking Dates';

  @override
  String get financials => 'Financials';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get advanceAmount => 'Advance Amount';

  @override
  String get inWords => 'In Words';

  @override
  String get inWordsHint => 'Auto-generated if blank';

  @override
  String get requiredField => 'Required';

  @override
  String get addDate => 'Add Date';

  @override
  String get eventDate => 'Event Date';

  @override
  String get timeSlot => 'Time Slot';

  @override
  String get addedDates => 'Added Dates';

  @override
  String get pleaseAddDate => 'Please add at least one booking date.';

  @override
  String get pleaseSelectDate => 'Please select a date first.';

  @override
  String get bookingCreatedSuccess => 'Booking created successfully!';

  @override
  String get bookingFailed => 'Failed to create booking.';

  @override
  String get removeDate => 'Remove Date';
}
