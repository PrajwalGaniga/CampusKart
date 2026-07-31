import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/feed_provider.dart';

class CreateAskScreen extends ConsumerStatefulWidget {
  const CreateAskScreen({super.key});

  @override
  ConsumerState<CreateAskScreen> createState() => _CreateAskScreenState();
}

class _CreateAskScreenState extends ConsumerState<CreateAskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'ACADEMIC';

  final List<String> _categories = [
    'ACADEMIC', 'ITEMS', 'FOOD', 'TRANSPORT', 'LOCATION', 'EMERGENCY', 'EVENT', 'OTHER'
  ];

  void _submit() async {
    final data = {
      'title': _titleController.text,
      'description': _descController.text,
      'category': _selectedCategory,
      'location': _locationController.text,
      'expires_in_minutes': 60,
    };

    try {
      await ref.read(feedProvider.notifier).createAsk(data);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Ask')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 12),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
              controller: _descController, 
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Post Ask'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
