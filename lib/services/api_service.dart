import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paginated_response.dart'; // <-- Import the new model
import 'package:intl/intl.dart';
import 'auth_service.dart';
import 'permission_service.dart'; // <-- 1. Import the new permission service


class ApiService {
  // IMPORTANT: Replace with your computer's IP address.
  // Do NOT use localhost or 127.0.0.1, as the Android emulator runs in its own virtual machine.
  // Find your IP by typing 'ipconfig' (Windows) or 'ifconfig' (macROS/Linux) in your terminal.
  final String _baseUrl = "http://192.168.0.101:8000/api"; // Example IP

  Map<String, String> _getAuthHeaders() {
    final token = AuthService().token; // Get token directly from AuthService
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

    Future<PaginatedResponse> _getPaginated(
    String endpoint, {
    int page = 1,
    String? query,
    String? startDate,
    String? endDate,
    int? categoryId,
    int? lenderId,
  }) async {
    // ** THE FIX: Use the AuthService for a clean, synchronous check **
    if (!AuthService().isLoggedIn) {
      print('[ApiService] ERROR: User not logged in. Cannot fetch $endpoint.');
      return PaginatedResponse(items: [], currentPage: 1, lastPage: 1);
    }

    try {
      // Build the query parameters map dynamically
      final Map<String, String> queryParameters = {'page': page.toString()};
      if (query != null && query.isNotEmpty) queryParameters['search'] = query;
      if (startDate != null) queryParameters['start_date'] = startDate;
      if (endDate != null) queryParameters['end_date'] = endDate;
      if (categoryId != null) queryParameters['category_id'] = categoryId.toString();
      if (lenderId != null) queryParameters['lender_id'] = lenderId.toString();

      final uri = Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: queryParameters);

      print('[ApiService] Requesting URL: $uri');
      
      // The _getAuthHeaders() method now handles getting the token
      final response = await http.get(uri, headers: _getAuthHeaders());

      print('[ApiService] Response Status Code for $endpoint: ${response.statusCode}');

      if (response.statusCode == 200) {
        // The parsing logic remains the same and is correct
        final decodedJson = jsonDecode(response.body);
        final paginatedResponse = PaginatedResponse.fromJson(decodedJson);
        print('[ApiService] SUCCESS: Parsed PaginatedResponse for $endpoint.');
        return paginatedResponse;
      } else {
        print('[ApiService] API returned non-200 status for $endpoint: ${response.body}');
      }
    } catch (e) {
      print('[ApiService] NETWORK ERROR fetching paginated data for $endpoint: $e');
    }

    // Return a default empty response if any error occurs
    return PaginatedResponse(items: [], currentPage: 1, lastPage: 1);
  }

  // --- CONCRETE IMPLEMENTATIONS (now very clean) ---
  Future<PaginatedResponse> getBookings({
    int page = 1,
    String? query,
    // ** ADD THESE NEW PARAMETERS **
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Format the dates into "YYYY-MM-DD" strings for the API
    final String? startDateStr = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null;
    final String? endDateStr = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null;

    // Call the generic helper with all possible filters
    return _getPaginated(
      'bookings',
      page: page,
      query: query,
      startDate: startDateStr,
      endDate: endDateStr,
    );
  }

Future<PaginatedResponse> getExpenses({
    int page = 1,
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
  }) async {
    // ** THE FIX: Format dates into strings before calling the helper **
    final String? startDateStr = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null;
    final String? endDateStr = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null;
    
    return _getPaginated('expenses', page: page, startDate: startDateStr, endDate: endDateStr, categoryId: categoryId);
  }

  // Find your existing getIncomes method
  Future<PaginatedResponse> getIncomes({
    int page = 1,
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
  }) async {
    // ** THE FIX: Format dates into strings before calling the helper **
    final String? startDateStr = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null;
    final String? endDateStr = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null;

    return _getPaginated('incomes', page: page, startDate: startDateStr, endDate: endDateStr, categoryId: categoryId);
  }

  Future<PaginatedResponse> getSalaries({int page = 1}) async {
    return _getPaginated('salaries', page: page);
  }

    Future<PaginatedResponse> getBorrowedFunds({
    int page = 1,
    DateTime? startDate,
    DateTime? endDate,
    int? lenderId,
  }) async {
    // ** THE FIX: Format the DateTime objects into strings before calling the helper **
    final String? startDateStr = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null;
    final String? endDateStr = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null;
    
    return _getPaginated(
      'borrowed-funds',
      page: page,
      startDate: startDateStr,
      endDate: endDateStr,
      lenderId: lenderId,
    );
  }

    Future<PaginatedResponse> getTransactions({
    int page = 1,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // These lines will no longer cause an error
    final String? startDateStr = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : null;
    final String? endDateStr = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null;
    
    return _getPaginated('transactions', page: page, startDate: startDateStr, endDate: endDateStr);
  }


   Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('[ApiService Login] Status Code: ${response.statusCode}');
      print('[ApiService Login] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = data['user'];
        final permissions = user['permissions'];
        
        // ** THE FIX: Use the new, single method to save everything **
        if (user != null && permissions is List) {
          await AuthService().saveAuthData(
            token: token,
            user: user,
            permissions: permissions,
          );
        }
        
        return token;
      }
    } catch (e) {
      print('[ApiService Login] Error during login request: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getDashboardStats() async {
    if (!AuthService().isLoggedIn) return null;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/dashboard-stats'), headers: _getAuthHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print('Error getting dashboard stats: $e'); }
    return null;
  }

  /*  Future<List<dynamic>> getBookings() async {
     if (!AuthService().isLoggedIn) return null; 

    final response = await http.get(
      Uri.parse('$_baseUrl/bookings'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      // We only need the 'data' part of the paginated response
      return jsonDecode(response.body)['data'];
    } else {
      return [];
    }
  } */

  Future<Map<String, dynamic>?> getBookingDetails(int id) async {
     if (!AuthService().isLoggedIn) return null; 

    final response = await http.get(
      Uri.parse('$_baseUrl/bookings/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> addBookingPayment({
    required int bookingId,
    required String amount,
    required String date,
    required String method,
    String? notes,
  }) async {
    if (!AuthService().isLoggedIn) return null;

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
      headers: _getAuthHeaders(),
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
     if (!AuthService().isLoggedIn) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/expense-categories'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  // To get the list of all expenses
  /*  Future<List<dynamic>> getExpenses() async {
     if (!AuthService().isLoggedIn) return null; 

    final response = await http.get(
      Uri.parse('$_baseUrl/expenses'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }
 */
  // To create a new expense
  Future<Map<String, dynamic>?> addExpense({
    required int categoryId,
    required String amount,
    required String date,
    String? description,
  }) async {
    if (!AuthService().isLoggedIn) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/expenses'),
      headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/expenses/$id'),
      headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return null;

    final response = await http.put(
      Uri.parse('$_baseUrl/expenses/$id'),
      headers: _getAuthHeaders(),
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
     if (!AuthService().isLoggedIn) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/expenses/$id'),
      headers: _getAuthHeaders(),
    );

    return response.statusCode == 204; // 204 No Content
  }

  Future<List<dynamic>> getIncomeCategories() async {
     if (!AuthService().isLoggedIn) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/income-categories'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }

  /*  Future<List<dynamic>> getIncomes() async {
     if (!AuthService().isLoggedIn) return null; 

    final response = await http.get(
      Uri.parse('$_baseUrl/incomes'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return [];
  }
 */
  Future<Map<String, dynamic>?> getIncome(int id) async {
    if (!AuthService().isLoggedIn) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/incomes/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    return null;
  }

  Future<bool> deleteIncome(int id) async {
    if (!AuthService().isLoggedIn) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/incomes/$id'),
      headers: _getAuthHeaders(),
    );

    return response.statusCode == 204;
  }

  Future<Map<String, dynamic>?> addIncome({
    required int categoryId,
    required String amount,
    required String date,
    String? description,
  }) async {
    if (!AuthService().isLoggedIn) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/incomes'),
      headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return null;
  

    final response = await http.put(
      Uri.parse('$_baseUrl/incomes/$id'),
      headers: _getAuthHeaders(),
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
      if (!AuthService().isLoggedIn) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/workers'),
        headers: _getAuthHeaders(),
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
     if (!AuthService().isLoggedIn) return false; 

    final Map<String, String> body = {
      'name': name,
      'monthly_salary': salary,
      'phone': phone ?? '',
      'designation': designation ?? '',
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workers'),
        headers: _getAuthHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // 201 Created
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
    if (!AuthService().isLoggedIn) return false;

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
        headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/workers/$id'),
        headers: _getAuthHeaders(),
      );

      return response.statusCode ==
          204; // 204 No Content is a success for delete
    } catch (e) {
      print('Error deleting worker: $e');
    }
    return false;
  }

  // -------------------------------------------------------------------
  // *****                SALARY MANAGEMENT METHODS                *****
  // -------------------------------------------------------------------

  /*   Future<List<dynamic>> getSalaries() async {
     if (!AuthService().isLoggedIn) return null; 

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/salaries'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print('Error fetching salaries: $e');
    }
    return [];
  }
 */
  Future<Map<String, dynamic>?> getSalaryDetails(int id) async {
    if (!AuthService().isLoggedIn) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/salaries/$id'),
        headers: _getAuthHeaders(),
      );

      // ***** ADD THIS DEBUGGING BLOCK *****
      print('--- Salary Detail Response ---');
      print('Status Code: ${response.statusCode}');
      print(
        'Response Body: ${response.body}',
      ); // This will print the raw HTML error page
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
    if (!AuthService().isLoggedIn) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/salaries/generate'),
        headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return null;

    final Map<String, String> body = {
      'payment_amount': amount,
      'payment_date': date,
      'notes': notes ?? '',
    };

    print('Sending Salary Payment Data: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/salaries/$monthlySalaryId/payments'),
        headers: _getAuthHeaders(),
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
     if (!AuthService().isLoggedIn) return [];
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lenders'),
        headers: _getAuthHeaders(),
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
  /*  Future<List<dynamic>> getBorrowedFunds() async {
     if (!AuthService().isLoggedIn) return null; 
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/borrowed-funds'),
        headers: _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
    } catch (e) {
      print('Error fetching borrowed funds: $e');
    }
    return [];
  }
 */
  /// Fetches the detailed information for a single borrowed fund.
  Future<Map<String, dynamic>?> getBorrowedFundDetails(int id) async {
    if (!AuthService().isLoggedIn) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/borrowed-funds/$id'),
        headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/borrowed-funds'),
        headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return null;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/borrowed-funds/$borrowedFundId/repayments'),
        headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/lenders'),
        headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return false;
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/lenders/$id'),
        headers: _getAuthHeaders(),
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
    if (!AuthService().isLoggedIn) return false;
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/lenders/$id'),
        headers: _getAuthHeaders(),
      );
      return response.statusCode == 204; // No Content
    } catch (e) {
      print('Error deleting lender: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> getLenderDetails(int id) async {
    if (!AuthService().isLoggedIn) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lenders/$id'),
        headers: _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(
          response.body,
        ); // The response is not nested under 'data' this time
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
     if (!AuthService().isLoggedIn) return null; 

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
        headers: _getAuthHeaders(),
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

}
