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
  String get eventTypeWedding => 'Wedding';

  @override
  String get eventTypeGayeHolud => 'Gaye Holud';

  @override
  String get eventTypeBirthday => 'Birthday';

  @override
  String get eventTypeAqiqah => 'Aqiqah';

  @override
  String get eventTypeMezban => 'Mezban';

  @override
  String get eventTypeSeminar => 'Seminar';

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
  String get slotDay => 'Day';

  @override
  String get slotNight => 'Night';

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

  @override
  String get bookingDetailsTitle => 'Booking Details';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get failedToLoadBooking => 'Failed to load booking details.';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get amountDue => 'Amount Due';

  @override
  String get bookingInformation => 'Booking Information';

  @override
  String get scheduledDates => 'Scheduled Dates';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get noDatesScheduled => 'No dates scheduled.';

  @override
  String get noPaymentsRecorded => 'No payments recorded yet.';

  @override
  String get amountToPay => 'Amount to Pay';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get submit => 'Submit';

  @override
  String get paymentAddedSuccess => 'Payment added successfully!';

  @override
  String get paymentFailed => 'Failed to add payment. Check input.';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodBank => 'Bank Transfer';

  @override
  String get paymentMethodMobile => 'Mobile Banking';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get logNewIncome => 'Log New Income';

  @override
  String get category => 'Category';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get amount => 'Amount';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get date => 'Date';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get updateIncome => 'Update Income';

  @override
  String get saveIncome => 'Save Income';

  @override
  String get incomeUpdatedSuccess => 'Income updated successfully!';

  @override
  String get incomeLoggedSuccess => 'Income logged successfully!';

  @override
  String get failedToUpdateIncome => 'Failed to update income.';

  @override
  String get failedToLogIncome => 'Failed to log income.';

  @override
  String get allIncomes => 'All Other Income';

  @override
  String get filterIncomes => 'Filter Incomes';

  @override
  String get logIncome => 'Log Income';

  @override
  String get noIncomesFound =>
      'No income records found for the selected filters.';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get areYouSureDeleteIncome =>
      'Are you sure you wish to delete this income record?';

  @override
  String get incomeDeleted => 'Income record deleted';

  @override
  String get failedToDeleteIncome => 'Failed to delete income';

  @override
  String get delete => 'Delete';

  @override
  String get filters => 'Filters:';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get loadMore => 'Load More';

  @override
  String get filterOptions => 'Filter Options';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get logNewExpense => 'Log New Expense';

  @override
  String get updateExpense => 'Update Expense';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get expenseUpdatedSuccess => 'Expense updated successfully!';

  @override
  String get expenseLoggedSuccess => 'Expense logged successfully!';

  @override
  String get failedToUpdateExpense => 'Failed to update expense.';

  @override
  String get failedToLogExpense => 'Failed to log expense.';

  @override
  String get allExpenses => 'All Expenses';

  @override
  String get filterExpenses => 'Filter Expenses';

  @override
  String get logExpense => 'Log Expense';

  @override
  String get noExpensesFound => 'No expenses found for the selected filters.';

  @override
  String get areYouSureDeleteExpense =>
      'Are you sure you wish to delete this expense?';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get failedToDeleteExpense => 'Failed to delete expense';

  @override
  String get noDescription => 'No description';

  @override
  String get salaryDetails => 'Salary Details';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get failedToLoadSalary => 'Failed to load salary details.';

  @override
  String get totalSalary => 'Total Salary';

  @override
  String get salaryInformation => 'Salary Information';

  @override
  String get worker => 'Worker:';

  @override
  String get salaryFor => 'Salary For:';

  @override
  String get status => 'Status:';

  @override
  String get noPaymentsThisMonth => 'No payments recorded for this month.';

  @override
  String get paymentRecordedSuccess => 'Payment recorded successfully!';

  @override
  String get failedToRecordPayment => 'Failed to record payment.';

  @override
  String get generateSalaries => 'Generate Salaries for a Month';

  @override
  String get selectMonthAndYear => 'Select Month and Year to Generate';

  @override
  String salariesGeneratedSuccess(Object monthYear) {
    return 'Salaries for $monthYear generated successfully!';
  }

  @override
  String get failedToGenerateSalaries => 'Failed to generate salaries.';

  @override
  String get noSalaryRecordsFound =>
      'No salary records found.\nTry generating for a month.';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusPartiallyPaid => 'Partially Paid';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String get filterFunds => 'Filter Funds';

  @override
  String get recordBorrowedFund => 'Record Borrowed Fund';

  @override
  String get noFundsFound =>
      'No borrowed funds found for the selected filters.';

  @override
  String get from => 'From:';

  @override
  String get on => 'on';

  @override
  String get lenderSource => 'Lender/Source';

  @override
  String get statusRepaid => 'Repaid';

  @override
  String get statusPartiallyRepaid => 'Partially Repaid';

  @override
  String get statusDue => 'Due';

  @override
  String get manageRepayments => 'Manage Repayments';

  @override
  String get recordRepayment => 'Record Repayment';

  @override
  String get failedToLoadDetails => 'Failed to load details.';

  @override
  String get totalBorrowed => 'Total Borrowed';

  @override
  String get totalRepaid => 'Total Repaid';

  @override
  String get loanInformation => 'Loan Information';

  @override
  String get purpose => 'Purpose:';

  @override
  String get dateBorrowed => 'Date Borrowed:';

  @override
  String get repaymentHistory => 'Repayment History';

  @override
  String get noRepaymentsRecorded => 'No repayments recorded for this loan.';

  @override
  String get repaymentRecordedSuccess => 'Repayment recorded successfully!';

  @override
  String get failedToRecordRepayment => 'Failed to record repayment.';

  @override
  String get retry => 'Retry';

  @override
  String get pleaseSelectLender => 'Please select a lender/source';

  @override
  String get amountBorrowed => 'Amount Borrowed';

  @override
  String get pleaseEnterPurpose => 'Please enter a purpose';

  @override
  String get saveRecord => 'Save Record';

  @override
  String get fundRecordCreatedSuccess => 'Fund record created successfully!';

  @override
  String get failedToCreateRecord => 'Failed to create record.';

  @override
  String get stayLoggedIn => 'Stay Logged In';

  @override
  String get login => 'Log In';

  @override
  String get welcomeToLogin => 'Welcome Back! Sign in to continue.';
}
