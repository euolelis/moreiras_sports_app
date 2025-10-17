    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:go_router/go_router.dart';
    import 'package:image_picker/image_picker.dart';
    import '../../../core/models/sponsor_model.dart';
    import '../../../core/services/firestore_service.dart';
    import '../../../core/services/storage_service.dart';

    class AddEditSponsorScreen extends ConsumerStatefulWidget {
      const AddEditSponsorScreen({super.key});

      @override
      ConsumerState<AddEditSponsorScreen> createState() => _AddEditSponsorScreenState();
    }

    class _AddEditSponsorScreenState extends ConsumerState<AddEditSponsorScreen> {
      final _formKey = GlobalKey<FormState>();
      final _nameController = TextEditingController();
      final _websiteController = TextEditingController();
      XFile? _selectedImageFile;
      bool _isLoading = false;

      Future<void> _pickImage() async {
        final image = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) setState(() => _selectedImageFile = image);
      }

      Future<void> _saveSponsor() async {
        if (_formKey.currentState!.validate()) {
          if (_selectedImageFile == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione um logo.')));
            return;
          }
          setState(() => _isLoading = true);
          try {
            final logoUrl = await ref.read(storageServiceProvider).uploadSponsorLogo(_selectedImageFile!);
            final sponsor = Sponsor(
              id: '',
              name: _nameController.text,
              logoUrl: logoUrl,
              website: _websiteController.text,
            );
            await ref.read(firestoreServiceProvider).setSponsor(sponsor);
            if (mounted) context.pop();
          } catch (e) {
            // Tratar erro
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Novo Patrocinador')),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: _selectedImageFile != null
                              ? Image.network(_selectedImageFile!.path, fit: BoxFit.contain)
                              : const Center(child: Text('Clique para selecionar o logo')),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome do Patrocinador'),
                        validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(labelText: 'Site (Opcional)'),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(onPressed: _saveSponsor, child: const Text('Salvar Patrocinador')),
                    ],
                  ),
                ),
        );
      }
    }