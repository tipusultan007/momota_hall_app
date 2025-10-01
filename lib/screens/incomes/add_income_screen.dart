import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart'; // Import the l10n class

class AddIncomeScreen extends StatefulWidget {
  final int? incomeId;
  const AddIncomeScreen({super.key, this.incomeId});
  
  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedCategoryId;
  List<dynamic>? _categories;
  bool _isLoading = true;
  bool get _isEditMode => widget.incomeId != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    final categories = await _apiService.getIncomeCategories();
    if (_isEditMode) {
      final incomeData = await _apiService.getIncome(widget.incomeId!);
      if (incomeData != null) {
        _amountController.text = incomeData['amount'].replaceAll(',', '');
        _dateController.text = DateFormat('yyyy-MM-dd').format(DateFormat('MMM d, yyyy').parse(incomeData['date']));
        _descriptionController.text = incomeData['description'] ?? '';
        _selectedCategoryId = categories?.firstWhere((cat) => cat['name'] == incomeData['category_name'], orElse: () => null)?['id'];
      }
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    
    if (mounted) {
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitIncome() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final apiCall = _isEditMode
          ? _apiService.updateIncome(
              id: widget.incomeId!,
              categoryId: _selectedCategoryId!,
              amount: _amountController.text,
              date: _dateController.text,
              description: _descriptionController.text,
            )
          : _apiService.addIncome(
              categoryId: _selectedCategoryId!,
              amount: _amountController.text,
              date: _dateController.text,
              description: _descriptionController.text,
            );
            
      final result = await apiCall;
      
      if (mounted) {
        if (result != null) {
          final successMessage = _isEditMode ? l10n.incomeUpdatedSuccess : l10n.incomeLoggedSuccess;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        } else {
          final errorMessage = _isEditMode ? l10n.failedToUpdateIncome : l10n.failedToLogIncome;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
          setState(() { _isLoading = false; });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? l10n.editIncome : l10n.logNewIncome)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_categories != null)
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      items: _categories!.map((cat) => DropdownMenuItem<int>(
                        value: cat['id'] as int,
                        child: Text(cat['name']),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedCategoryId = value),
                      decoration: InputDecoration(labelText: l10n.category, border: const OutlineInputBorder()),
                      validator: (value) => value == null ? l10n.pleaseSelectCategory : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder(), prefixText: '৳'),
                      keyboardType: TextInputType.number,
                      validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterAmount : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(labelText: l10n.date, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today)),
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (picked != null) _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: l10n.descriptionOptional, border: const OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitIncome,
                      child: Text(_isEditMode ? l10n.updateIncome : l10n.saveIncome),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}