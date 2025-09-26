import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddEditWorkerScreen extends StatefulWidget {
  final Map<String, dynamic>? worker; // Pass worker data for editing
  
  const AddEditWorkerScreen({super.key, this.worker});

  @override
  State<AddEditWorkerScreen> createState() => _AddEditWorkerScreenState();
}

class _AddEditWorkerScreenState extends State<AddEditWorkerScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();
  final _salaryController = TextEditingController();
  
  bool _isActive = true;
  bool _isLoading = false;
  bool get _isEditMode => widget.worker != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // Pre-fill form if in edit mode
      _nameController.text = widget.worker!['name'];
      _phoneController.text = widget.worker!['phone'] ?? '';
      _designationController.text = widget.worker!['designation'] ?? '';
      _salaryController.text = widget.worker!['monthly_salary'].replaceAll(',', '');
      _isActive = widget.worker!['is_active'] == 1; 
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final apiCall = _isEditMode
          ? _apiService.updateWorker(
              id: widget.worker!['id'],
              name: _nameController.text,
              phone: _phoneController.text,
              designation: _designationController.text,
              salary: _salaryController.text,
              isActive: _isActive,
            )
          : _apiService.addWorker(
              name: _nameController.text,
              phone: _phoneController.text,
              designation: _designationController.text,
              salary: _salaryController.text,
            );
            
      final success = await apiCall;
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Worker ${_isEditMode ? 'updated' : 'added'} successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true); // Return 'true' to signal a refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to ${_isEditMode ? 'update' : 'add'} worker.'), backgroundColor: Colors.red),
          );
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Worker' : 'Add New Worker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(labelText: 'Designation (e.g., Manager)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Monthly Salary', border: OutlineInputBorder(), prefixText: '৳'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a salary' : null,
              ),
              if (_isEditMode)
                SwitchListTile(
                  title: const Text('Worker is Active'),
                  value: _isActive,
                  onChanged: (bool value) => setState(() => _isActive = value),
                ),
              const SizedBox(height: 32),
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isEditMode ? 'Update Worker' : 'Save Worker'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}