import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/gear_item.dart';
import '../providers/arsenal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bat_app_bar.dart';

class EditGearScreen extends StatefulWidget {
  final GearItem item;
  const EditGearScreen({super.key, required this.item});

  @override
  State<EditGearScreen> createState() => _EditGearScreenState();
}

class _EditGearScreenState extends State<EditGearScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  late int? _selectedDivisionId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(text: '${widget.item.quantity}');
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _selectedDivisionId = widget.item.divisionId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(ArsenalProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final success = await provider.updateGear(
      id: widget.item.id,
      name: _nameController.text.trim(),
      divisionId: _selectedDivisionId!,
      quantity: int.parse(_quantityController.text.trim()),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    setState(() => _submitting = false);
    if (success && mounted) Navigator.pop(context);
  }

  Future<void> _delete(ArsenalProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardElevated,
        title: Text('Delete Gear', style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16)),
        content: Text('Remove ${widget.item.name} from the arsenal?', style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: AppTheme.critical)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() => _submitting = true);
      await provider.deleteGear(widget.item.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArsenalProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: BatAppBar(
            title: 'EDIT GEAR',
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.critical),
                onPressed: _submitting ? null : () => _delete(provider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Gear Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedDivisionId,
                    dropdownColor: AppTheme.cardElevated,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Division'),
                    items: provider.divisions.map((d) {
                      return DropdownMenuItem(value: d.id, child: Text(d.name));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedDivisionId = v),
                    validator: (v) => v == null ? 'Select a division' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.wayneBlue.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitting ? null : () => _submit(provider),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'SAVE CHANGES',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _submitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.textSecondary),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'CANCEL',
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
