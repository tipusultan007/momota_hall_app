import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddEditLenderScreen extends StatefulWidget {
  final Map<String, dynamic>? lender; // Pass lender data for editing
  const AddEditLenderScreen({super.key, this.lender});
  @override
  State<AddEditLenderScreen> createState() => _AddEditLenderScreenState();
}

class _AddEditLenderScreenState extends State<AddEditLenderScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool get _isEditMode => widget.lender != null;
  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // Pre-fill form if editing
      _nameController.text = widget.lender!['name'];
      // The API resource for lenders doesn't include these, so let's assume they are there for now
      // We will need to update the LenderResource to include all fields.
      // _contactController.text = widget.lender!['contact_person'] ?? '';
      // _phoneController.text = widget.lender!['phone'] ?? '';
      // _notesController.text = widget.lender!['notes'] ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final apiCall = _isEditMode
          ? _apiService.updateLender(
              id: widget.lender!['id'],
              name: _nameController.text,
              contact: _contactController.text,
              phone: _phoneController.text,
              notes: _notesController.text,
            )
          : _apiService.addLender(
              name: _nameController.text,
              contact: _contactController.text,
              phone: _phoneController.text,
              notes: _notesController.text,
            );

      final success = await apiCall;

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lender ${_isEditMode ? 'updated' : 'added'} successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to ${_isEditMode ? 'update' : 'add'} lender.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Lender' : 'Add New Lender'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Lender Name/Source',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(
                        _isEditMode ? 'Update Lender' : 'Save Lender',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
