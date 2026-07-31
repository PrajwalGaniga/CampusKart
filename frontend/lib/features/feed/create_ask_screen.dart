import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/feed_provider.dart';
import '../../core/app_theme.dart';

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
  bool _isLoading = false;

  final List<String> _categories = [
    'ACADEMIC', 'ITEMS', 'FOOD', 'TRANSPORT', 'LOCATION', 'EMERGENCY', 'EVENT', 'OTHER'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_isLoading) return;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a title'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _selectedCategory,
      'location': _locationController.text.trim(),
      'expires_in_minutes': 60,
    };

    try {
      await ref.read(feedProvider.notifier).createAsk(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ask posted! 🎉'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header
          Container(
            decoration: primaryGradientDecoration(radius: 0),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                    const Text(
                      'Create an Ask',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category picker
                  const _SectionLabel(text: 'Category'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      final color = categoryColor(cat);
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                categoryIcon(cat),
                                size: 14,
                                color: isSelected ? Colors.white : color,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const _SectionLabel(text: 'Title'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'What do you need help with?',
                      prefixIcon: Icon(Icons.title_rounded, color: AppColors.textSecondary),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const _SectionLabel(text: 'Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      hintText: 'Add more details...',
                      prefixIcon: Icon(Icons.description_outlined, color: AppColors.textSecondary),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  const _SectionLabel(text: 'Location'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Where are you? (e.g. Library, Block A)',
                      prefixIcon: Icon(Icons.place_rounded, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  GestureDetector(
                    onTap: _isLoading ? null : _submit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 54,
                      decoration: _isLoading
                          ? BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                            )
                          : primaryGradientDecoration(radius: 14),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Post Ask',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }
}
