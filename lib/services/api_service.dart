import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IMPORTANT: Replace with your computer's IP address.
  // Do NOT use localhost or 127.0.0.1, as the Android emulator runs in its own virtual machine.
  // Find your IP by typing 'ipconfig' (Windows) or 'ifconfig' (macROS/Linux) in your terminal.
  final String _baseUrl = "http://192.168.0.106:8000/api"; // Example IP

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      String token = jsonDecode(response.body)['access_token'];
      // Store the token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    } else {
      // Handle error
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDashboardStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/dashboard-stats'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<List<dynamic>> getBookings() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/bookings'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      // We only need the 'data' part of the paginated response
      return jsonDecode(response.body)['data'];
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getBookingDetails(int id) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/bookings/$id'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      return null;
    }
  }

  // Helper methods to keep code clean
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _getAuthHeaders(String token) {
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<Map<String, dynamic>?> addBookingPayment({
    required int bookingId,
    required String amount,
    required String date,
    required String method,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    // 2. Prepare the data in a map first
    final Map<String, String> body = {
      'payment_amount': amount,
      'payment_date': date,
      'payment_method': method,
      'notes': notes ?? '', // Send an empty string if notes is null
    };

    // 3. Print the body before sending for easy debugging
    print('Sending Payment Data: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse('$_baseUrl/bookings/$bookingId/payments'),
      headers: _getAuthHeaders(token),
      body: jsonEncode(body), // Send the prepared map
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      print('API Error: ${response.body}');
      return null;
    }
  }

  // To get the category list for the form
  Future<List<dynamic>> getExpenseCategories() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/expense-categories'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  // To get the list of all expenses
  Future<List<dynamic>> getExpenses() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/expenses'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  // To create a new expense
  Future<Map<String, dynamic>?> addExpense({
    required int categoryId,
    required String amount,
    required String date,
    String? description,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/expenses'),
      headers: _getAuthHeaders(token),
      body: jsonEncode({
        'expense_category_id': categoryId.toString(),
        'amount': amount,
        'expense_date': date,
        'description': description ?? '',
      }),
    );

    if (response.statusCode == 201) {
      // 201 Created
      return jsonDecode(response.body)['data'];
    } else {
      print('API Error: ${response.body}');
      return null;
    }
  }

  // To get a single expense for the edit screen
  Future<Map<String, dynamic>?> getExpense(int id) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/expenses/$id'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return null;
  }

  // To update an existing expense
  Future<Map<String, dynamic>?> updateExpense({
    required int id,
    required int categoryId,
    required String amount,
    required String date,
    String? description,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.put(
      Uri.parse('$_baseUrl/expenses/$id'),
      headers: _getAuthHeaders(token),
      body: jsonEncode({
        'expense_category_id': categoryId.toString(),
        'amount': amount,
        'expense_date': date,
        'description': description ?? '',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      print('API Error: ${response.body}');
      return null;
    }
  }

  // To delete an expense
  Future<bool> deleteExpense(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/expenses/$id'),
      headers: _getAuthHeaders(token),
    );

    return response.statusCode == 204; // 204 No Content
  }

  Future<List<dynamic>> getIncomeCategories() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/income-categories'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  Future<List<dynamic>> getIncomes() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/incomes'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  Future<Map<String, dynamic>?> getIncome(int id) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/incomes/$id'),
      headers: _getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return null;
  }

  Future<bool> deleteIncome(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/incomes/$id'),
      headers: _getAuthHeaders(token),
    );

    return response.statusCode == 204;
  }

  Future<Map<String, dynamic>?> addIncome({
    required int categoryId,
    required String amount,
    required String date,
    String? description,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/incomes'),
      headers: _getAuthHeaders(token),
      body: jsonEncode({
        'income_category_id': categoryId.toString(),
        'amount': amount,
        'income_date': date,
        'description': description ?? '',
      }),
    );

    if (response.statusCode == 201) {
      // 201 Created
      return jsonDecode(response.body)['data'];
    } else {
      print('API Error: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateIncome({
    required int id,
    required int categoryId,
    required String amount,
    required String date,
    String? description,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.put(
      Uri.parse('$_baseUrl/incomes/$id'),
      headers: _getAuthHeaders(token),
      body: jsonEncode({
        'income_category_id': categoryId.toString(),
        'amount': amount,
        'income_date': date,
        'description': description ?? '',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      print('API Error: ${response.body}');
      return null;
    }
  }


  // -------------------------------------------------------------------
  // *****                WORKER MANAGEMENT METHODS                *****
  // -------------------------------------------------------------------

  Future<List<dynamic>> getWorkers() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/workers'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print('Error fetching workers: $e');
    }
    return [];
  }

 /// Adds a new worker.
  Future<bool> addWorker({
    required String name,
    required String salary,
    String? phone,
    String? designation,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final Map<String, String> body = {
      'name': name,
      'monthly_salary': salary,
      'phone': phone ?? '',
      'designation': designation ?? '',
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workers'),
        headers: _getAuthHeaders(token),
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 201) { // 201 Created
        return true;
      } else {
        print('API Error adding worker: ${response.body}');
      }
    } catch (e) {
      print('Error adding worker: $e');
    }
    return false;
  }

  /// Updates an existing worker's details.
    Future<bool> updateWorker({
    required int id,
    required String name,
    required String salary,
    required bool isActive,
    String? phone,
    String? designation,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final Map<String, dynamic> body = {
      'name': name,
      'monthly_salary': salary,
      'phone': phone ?? '',
      'designation': designation ?? '',
      
      // ***** THIS IS THE FIX *****
      // Convert the boolean to an integer (1 for true, 0 for false) before encoding to JSON.
      // This is the most universally compatible format for web APIs.
      'is_active': isActive ? '1' : '0',
    };
    
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/workers/$id'),
        headers: _getAuthHeaders(token),
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print('API Error updating worker: ${response.body}');
      }
    } catch (e) {
      print('Error updating worker: $e');
    }
    return false;
  }

  /// Deletes a worker.
  Future<bool> deleteWorker(int id) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/workers/$id'),
        headers: _getAuthHeaders(token),
      );

      return response.statusCode == 204; // 204 No Content is a success for delete
    } catch (e) {
      print('Error deleting worker: $e');
    }
    return false;
  }


  // -------------------------------------------------------------------
  // *****                SALARY MANAGEMENT METHODS                *****
  // -------------------------------------------------------------------

  Future<List<dynamic>> getSalaries() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/salaries'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print('Error fetching salaries: $e');
    }
    return [];
  }

   Future<Map<String, dynamic>?> getSalaryDetails(int id) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/salaries/$id'),
        headers: _getAuthHeaders(token),
      );

      // ***** ADD THIS DEBUGGING BLOCK *****
      print('--- Salary Detail Response ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // This will print the raw HTML error page
      print('----------------------------');
      // **********************************

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data']; 
      }
    } catch (e) {
      print('Error fetching salary details: $e');
    }
    return null;
  }

  Future<bool> generateSalaries(String monthYear) async {
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/salaries/generate'),
        headers: _getAuthHeaders(token),
        body: jsonEncode({'month': monthYear}), // e.g., "2025-10"
      );
      // Check for a successful status code (e.g., 200 OK or 201 Created)
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error generating salaries: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> addSalaryPayment({
    required int monthlySalaryId,
    required String amount,
    required String date,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    final Map<String, String> body = {
      'payment_amount': amount,
      'payment_date': date,
      'notes': notes ?? '',
    };
    
    print('Sending Salary Payment Data: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/salaries/$monthlySalaryId/payments'),
        headers: _getAuthHeaders(token),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        print('API Error adding salary payment: ${response.body}');
      }
    } catch (e) {
      print('Error adding salary payment: $e');
    }
    return null;
  }

  // -------------------------------------------------------------------
  // *****             LIABILITY MANAGEMENT METHODS              *****
  // -------------------------------------------------------------------

  /// Fetches a list of all lenders for dropdowns.
  Future<List<dynamic>> getLenders() async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lenders'),
        headers: _getAuthHeaders(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print('Error fetching lenders: $e');
    }
    return [];
  }

  /// Fetches a list of all borrowed funds (loans).
  Future<List<dynamic>> getBorrowedFunds() async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/borrowed-funds'),
        headers: _getAuthHeaders(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print('Error fetching borrowed funds: $e');
    }
    return [];
  }

  /// Fetches the detailed information for a single borrowed fund.
  Future<Map<String, dynamic>?> getBorrowedFundDetails(int id) async {
    final token = await _getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/borrowed-funds/$id'),
        headers: _getAuthHeaders(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print('Error fetching borrowed fund details: $e');
    }
    return null;
  }

  /// Adds a new borrowed fund record.
  Future<bool> addBorrowedFund({
    required int lenderId,
    required String amount,
    required String date,
    required String purpose,
  }) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/borrowed-funds'),
        headers: _getAuthHeaders(token),
        body: jsonEncode({
          'lender_id': lenderId.toString(),
          'amount_borrowed': amount,
          'date_borrowed': date,
          'purpose': purpose,
        }),
      );
      return response.statusCode == 201; // Created
    } catch (e) {
      print('Error adding borrowed fund: $e');
    }
    return false;
  }

  /// Adds a repayment to a specific borrowed fund.
  Future<Map<String, dynamic>?> addFundRepayment({
    required int borrowedFundId,
    required String amount,
    required String date,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) return null;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/borrowed-funds/$borrowedFundId/repayments'),
        headers: _getAuthHeaders(token),
        body: jsonEncode({
          'repayment_amount': amount,
          'repayment_date': date,
          'notes': notes ?? '',
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print('Error adding fund repayment: $e');
    }
    return null;
  }
 // -------------------------------------------------------------------
  // *****                LENDER MANAGEMENT METHODS                *****
  // -------------------------------------------------------------------
  
  // getLenders() already exists, which is great.

  Future<bool> addLender({
    required String name,
    String? contact,
    String? phone,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/lenders'),
        headers: _getAuthHeaders(token),
        body: jsonEncode({
          'name': name,
          'contact_person': contact ?? '',
          'phone': phone ?? '',
          'notes': notes ?? '',
        }),
      );
      return response.statusCode == 201; // Created
    } catch (e) {
      print('Error adding lender: $e');
    }
    return false;
  }

  Future<bool> updateLender({
    required int id,
    required String name,
    String? contact,
    String? phone,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/lenders/$id'),
        headers: _getAuthHeaders(token),
        body: jsonEncode({
          'name': name,
          'contact_person': contact ?? '',
          'phone': phone ?? '',
          'notes': notes ?? '',
        }),
      );
      return response.statusCode == 200; // OK
    } catch (e) {
      print('Error updating lender: $e');
    }
    return false;
  }

  Future<bool> deleteLender(int id) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/lenders/$id'),
        headers: _getAuthHeaders(token),
      );
      return response.statusCode == 204; // No Content
    } catch (e) {
      print('Error deleting lender: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> getLenderDetails(int id) async {
    final token = await _getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lenders/$id'),
        headers: _getAuthHeaders(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // The response is not nested under 'data' this time
      }
    } catch (e) {
      print('Error fetching lender details: $e');
    }
    return null;
  }
 Future<Map<String, dynamic>?> addBooking({
    required String customerName,
    required String customerPhone,
    String? customerAddress,
    required String eventType,
    String? receiptNo,
    String? guests,
    String? tables,
    String? servers,
    required String totalAmount,
    String? advanceAmount,
    String? notesInWords,
    required List<Map<String, String>> bookingDates,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    final body = {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress ?? '',
      'event_type': eventType,
      'receipt_no': receiptNo ?? '',
      'guests_count': guests ?? '',
      'tables_count': tables ?? '',
      'boys_count': servers ?? '',
      'total_amount': totalAmount,
      'advance_amount': advanceAmount ?? '0',
      'notes_in_words': notesInWords ?? '',
      'booking_dates': bookingDates,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bookings'),
        headers: _getAuthHeaders(token),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['data'];
      } else {
        print('API Error adding booking: ${response.body}');
      }
    } catch (e) {
      print('Error adding booking: $e');
    }
    return null;
  }

  // -------------------------------------------------------------------
  // *****            TRANSACTION LEDGER METHOD                  *****
  // -------------------------------------------------------------------

  /// Fetches a paginated list of all transactions (the general ledger).
  Future<List<dynamic>> getTransactions({int page = 1}) async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        // The API endpoint for fetching transactions, including the page number
        Uri.parse('$_baseUrl/transactions?page=$page'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        // The list of transactions is nested under the 'data' key
        // because Laravel's resource collections paginate results.
        return jsonDecode(response.body)['data'];
      } else {
        // Print an error if the request fails
        print('Failed to load transactions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
    
    // Return an empty list if anything goes wrong
    return [];
  }
}

