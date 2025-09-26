import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_edit_worker_screen.dart';

class WorkersListScreen extends StatefulWidget {
  const WorkersListScreen({super.key});
  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _workersFuture;

  @override
  void initState() {
    super.initState();
    _workersFuture = _apiService.getWorkers();
  }

  void _refreshWorkers() {
    setState(() {
      _workersFuture = _apiService.getWorkers();
    });
  }

  void _navigateToForm({Map<String, dynamic>? worker}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditWorkerScreen(worker: worker),
      ),
    );
    if (result == true) {
      _refreshWorkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Workers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
        tooltip: 'Add Worker',
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshWorkers(),
        child: FutureBuilder<List<dynamic>>(
          future: _workersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No workers found.'));
            }

            final workers = snapshot.data!;
            return ListView.builder(
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return Dismissible(
                  key: Key(worker['id'].toString()),
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
                          title: const Text("Confirm Delete"),
                          content: Text("Are you sure you want to delete ${worker['name']}?"),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("CANCEL")),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("DELETE")),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    bool deleted = await _apiService.deleteWorker(worker['id']);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(deleted ? 'Worker deleted' : 'Failed to delete worker')),
                      );
                      if (deleted) _refreshWorkers();
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(worker['name']),
                      subtitle: Text(worker['designation'] ?? 'No designation'),
                      leading: CircleAvatar(
                        child: Text(worker['name'].substring(0, 1)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('৳${worker['monthly_salary']}'),
                          const SizedBox(width: 8),
                          Icon(
                            worker['is_active'] == 1 ? Icons.check_circle : Icons.cancel,
                            color: worker['is_active'] == 1 ? Colors.green : Colors.grey,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () => _navigateToForm(worker: worker),
                          ),
                        ],
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