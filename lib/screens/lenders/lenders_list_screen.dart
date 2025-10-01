import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/permission_service.dart';
import 'add_edit_lender_screen.dart';
import 'lender_detail_screen.dart'; // <-- 1. Import the new screen


class LendersListScreen extends StatefulWidget {
  const LendersListScreen({super.key});
  @override
  State<LendersListScreen> createState() => _LendersListScreenState();
}

class _LendersListScreenState extends State<LendersListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _lendersFuture;

  @override
  void initState() {
    super.initState();
    _lendersFuture = _apiService.getLenders();
  }

  void _refresh() {
    setState(() {
      _lendersFuture = _apiService.getLenders();
    });
  }

  void _navigateToForm({Map<String, dynamic>? lender}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditLenderScreen(lender: lender),
      ),
    );
    if (result == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Lenders')),
      floatingActionButton: PermissionService().can('manage lenders')
          ? FloatingActionButton(
              onPressed: () => _navigateToForm(),
              child: const Icon(Icons.add),
              tooltip: 'Add Lender',
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<dynamic>>(
          future: _lendersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No lenders found.'));
            }

            final lenders = snapshot.data!;
            return ListView.builder(
              itemCount: lenders.length,
              itemBuilder: (context, index) {
                final lender = lenders[index];
                return Dismissible(
                  key: Key(lender['id'].toString()),
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
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: Text("Are you sure you want to delete ${lender['name']}?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("CANCEL")),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("DELETE")),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    bool deleted = await _apiService.deleteLender(lender['id']);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(deleted ? 'Lender deleted' : 'Failed to delete lender')),
                      );
                      if (deleted) _refresh();
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(lender['name']),
                      subtitle: Text(lender['contact_person'] ?? 'No contact person'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _navigateToForm(lender: lender),
                      ),
                      // **** 2. ADD THIS onTap CALLBACK ****
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LenderDetailScreen(lenderId: lender['id']),
                          ),
                        );
                      },
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