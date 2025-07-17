import 'package:flutter/material.dart';

class AddFeatureDialog extends StatefulWidget {
  const AddFeatureDialog({super.key});

  @override
  State<AddFeatureDialog> createState() => _AddFeatureDialogState();
}

class _AddFeatureDialogState extends State<AddFeatureDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Feature'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Feature Title *',
                hintText: 'Enter a descriptive title',
                border: OutlineInputBorder(),
              ),
              maxLength: 255,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Provide more details about the feature',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 1000,
              validator: (value) {
                if (value != null && value.length > 1000) {
                  return 'Description must not exceed 1000 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final title = _titleController.text.trim();
              final description = _descriptionController.text.trim();

              Navigator.of(context).pop({
                'title': title,
                'description': description.isEmpty ? null : description,
              });
            }
          },
          child: const Text('Add Feature'),
        ),
      ],
    );
  }
}
