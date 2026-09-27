import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/profile_provider.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _teachController = TextEditingController();
  final _learnController = TextEditingController();

  final List<String> _skillsToTeach = [];
  final List<String> _skillsToLearn = [];
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final existing = context.read<ProfileProvider>().profile;
    if (existing != null) {
      _nameController.text = existing.name;
      _bioController.text = existing.bio;
      _skillsToTeach.addAll(existing.skillsToTeach);
      _skillsToLearn.addAll(existing.skillsToLearn);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _addChip(TextEditingController controller, List<String> list) {
    final value = controller.text.trim();
    if (value.isEmpty || list.contains(value)) return;
    setState(() {
      list.add(value);
      controller.clear();
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skillsToTeach.isEmpty || _skillsToLearn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one skill to teach and learn'),
        ),
      );
      return;
    }

    final authUser = context.read<AuthProvider>().user!;
    final success = await context.read<ProfileProvider>().saveProfile(
      uid: authUser.uid,
      email: authUser.email ?? '',
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      skillsToTeach: _skillsToTeach,
      skillsToLearn: _skillsToLearn,
      newImageFile: _pickedImage,
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save profile. Try again.')),
      );
    }
  }

  Widget _buildChipInput({
    required String label,
    required TextEditingController controller,
    required List<String> chips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'e.g. Flutter'),
                onSubmitted: (_) => _addChip(controller, chips),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              onPressed: () => _addChip(controller, chips),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: chips
              .map(
                (s) => Chip(
                  label: Text(s),
                  onDeleted: () => setState(() => chips.remove(s)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Your Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple.shade50,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : null,
                      child: _pickedImage == null
                          ? const Icon(
                              Icons.add_a_photo_outlined,
                              size: 32,
                              color: Colors.deepPurple,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell others a bit about yourself',
                  ),
                ),
                const SizedBox(height: 20),
                _buildChipInput(
                  label: 'Skills I can teach',
                  controller: _teachController,
                  chips: _skillsToTeach,
                ),
                _buildChipInput(
                  label: 'Skills I want to learn',
                  controller: _learnController,
                  chips: _skillsToLearn,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: profileState.isLoading ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: profileState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
