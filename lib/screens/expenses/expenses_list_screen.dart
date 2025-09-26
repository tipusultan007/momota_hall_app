import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_expense_screen.dart'; // We will create this next

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});
  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = _apiService.getExpenses();
  }

  void _refreshExpenses() {
    setState(() {
      _expensesFuture = _apiService.getExpenses();
    });
  }

  void _navigateToAddExpense() async {
    // Navigate to the add screen and wait for a result
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
    // If the result is true, it means a new expense was added, so refresh the list
    if (result == true) {
      _refreshExpenses();
    }
  }

    void _navigateToEditExpense(int expenseId) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddExpenseScreen(expenseId: expenseId)), // Pass the ID
    );
    if (result == true) {
      _refreshExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        child: const Icon(Icons.add),
        tooltip: 'Log Expense',
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshExpenses(),
        child: FutureBuilder<List<dynamic>>(
          future: _expensesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No expenses found.'));
            }

            final expenses = snapshot.data!;
            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                
                // **** WRAP THE CARD IN A DISMISSIBLE WIDGET ****
                return Dismissible(
                  key: Key(expense['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text("Are you sure you wish to delete this expense?"),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("CANCEL")),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("DELETE")),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    bool deleted = await _apiService.deleteExpense(expense['id']);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(deleted ? 'Expense deleted' : 'Failed to delete expense'),
                          backgroundColor: deleted ? Colors.green : Colors.red,
                        ),
                      );
                      if(deleted) _refreshExpenses();
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('৳${expense['amount'] ?? '0.00'} - ${expense['category_name'] ?? 'N/A'}'),
                      subtitle: Text(expense['description'] ?? 'No description'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _navigateToEditExpense(expense['id']), // <-- Add edit navigation
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}