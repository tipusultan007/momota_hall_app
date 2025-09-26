import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_income_screen.dart'; // We will create this next

class IncomesListScreen extends StatefulWidget {
  const IncomesListScreen({super.key});
  @override
  State<IncomesListScreen> createState() => _IncomesListScreenState();
}

class _IncomesListScreenState extends State<IncomesListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _incomesFuture;

  @override
  void initState() {
    super.initState();
    _incomesFuture = _apiService.getIncomes();
  }

  void _refreshIncomes() {
    setState(() {
      _incomesFuture = _apiService.getIncomes();
    });
  }

  void _navigateToAddIncome() async {
    // Navigate to the add screen and wait for a result
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
    );
    // If the result is true, it means a new income was added, so refresh the list
    if (result == true) {
      _refreshIncomes();
    }
  }

    void _navigateToEditIncome(int incomeId) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddIncomeScreen(incomeId: incomeId)), // Pass the ID
    );
    if (result == true) {
      _refreshIncomes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Incomes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddIncome,
        child: const Icon(Icons.add),
        tooltip: 'Log Income',
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshIncomes(),
        child: FutureBuilder<List<dynamic>>(
          future: _incomesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No incomes found.'));
            }

            final incomes = snapshot.data!;
            return ListView.builder(
              itemCount: incomes.length,
              itemBuilder: (context, index) {
                final income = incomes[index];
                
                // **** WRAP THE CARD IN A DISMISSIBLE WIDGET ****
                return Dismissible(
                  key: Key(income['id'].toString()),
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
                          content: const Text("Are you sure you wish to delete this income?"),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("CANCEL")),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("DELETE")),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    bool deleted = await _apiService.deleteIncome(income['id']);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(deleted ? 'Income deleted' : 'Failed to delete income'),
                          backgroundColor: deleted ? Colors.green : Colors.red,
                        ),
                      );
                      if(deleted) _refreshIncomes();
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('৳${income['amount'] ?? '0.00'} - ${income['category_name'] ?? 'N/A'}'),
                      subtitle: Text(income['description'] ?? 'No description'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _navigateToEditIncome(income['id']), // <-- Add edit navigation
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