import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/models/sponsor_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import 'manage_categories_screen.dart';

// Provider para buscar um patrocinador específico (necessário para a edição)
final sponsorDetailProvider = FutureProvider.autoDispose.family<Sponsor, String>((ref, sponsorId) {
  // Este método precisará ser criado no FirestoreService
  return ref.watch(firestoreServiceProvider).getSponsorById(sponsorId);
});

class AddEditSponsorScreen extends ConsumerWidget {
  final String? sponsorId;
  const AddEditSponsorScreen({super.key, this.sponsorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sponsorId != null) {
      final sponsorAsync = ref.watch(sponsorDetailProvider(sponsorId!));
      return sponsorAsync.when(
        data: (sponsor) => _SponsorForm(sponsor: sponsor),
        loading: () => Scaffold(appBar: AppBar(title: const Text('Editar Patrocinador')), body: const Center(child: CircularProgressIndicator())),
        error: (e, s) => Scaffold(appBar: AppBar(title: const Text('Erro')), body: Center(child: Text('Erro ao carregar: $e'))),
      );
    } else {
      return const _SponsorForm();
    }
  }
}

class _SponsorForm extends ConsumerStatefulWidget {
  final Sponsor? sponsor;
  const _SponsorForm({this.sponsor});

  @override
  ConsumerState<_SponsorForm> createState() => _SponsorFormState();
}

class _SponsorFormState extends ConsumerState<_SponsorForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _websiteController;
  late TextEditingController _whatsappController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  Uint8List? _selectedImageBytes;
  XFile? _selectedImageFile;
  String? _existingLogoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.sponsor;
    _nameController = TextEditingController(text: s?.name ?? '');
    _websiteController = TextEditingController(text: s?.website ?? '');
    _whatsappController = TextEditingController(text: s?.whatsapp ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _selectedCategoryId = s?.categoryId;
    _existingLogoUrl = s?.logoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _whatsappController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageFile = image;
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _saveSponsor() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    String logoUrl = _existingLogoUrl ?? '';

    try {
      if (_selectedImageFile != null) {
        logoUrl = await ref.read(storageServiceProvider).uploadSponsorLogo(_selectedImageFile!);
      }

      final sponsorToSave = Sponsor(
        id: widget.sponsor?.id ?? '',
        name: _nameController.text,
        logoUrl: logoUrl,
        categoryId: _selectedCategoryId ?? '',
        description: _descriptionController.text,
        website: _websiteController.text,
        whatsapp: _whatsappController.text,
      );

      await ref.read(firestoreServiceProvider).setSponsor(sponsorToSave);
      if (mounted) {
        context.go('/admin/manage-sponsors', extra: 'Patrocinador salvo com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sponsor == null ? 'Adicionar Patrocinador' : 'Editar Patrocinador'),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome do Patrocinador', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
                  const SizedBox(height: 16),
                  Consumer(builder: (context, ref, child) {
                    final categoriesAsync = ref.watch(categoriesStreamProvider);
                    return categoriesAsync.when(
                      data: (categories) => DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        hint: const Text('Selecione a Categoria'),
                        decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Geral (Todas as Categorias)')),
                          ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (value) => setState(() => _selectedCategoryId = value),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => const Text('Erro ao carregar categorias'),
                    );
                  }),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150, width: 150,
                      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
                      child: _buildImageWidget(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()), maxLines: 3),
                  const SizedBox(height: 16),
                  TextFormField(controller: _websiteController, decoration: const InputDecoration(labelText: 'Site ou Rede Social', border: OutlineInputBorder()), keyboardType: TextInputType.url),
                  const SizedBox(height: 16),
                  TextFormField(controller: _whatsappController, decoration: const InputDecoration(labelText: 'WhatsApp (Ex: 55119...))', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: _saveSponsor, child: const Text('Salvar Patrocinador')),
                ],
              ),
            ),
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImageBytes != null) {
      return Image.memory(_selectedImageBytes!, fit: BoxFit.contain);
    }
    if (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty) {
      return CachedNetworkImage(imageUrl: _existingLogoUrl!, fit: BoxFit.contain, placeholder: (c, u) => const CircularProgressIndicator(), errorWidget: (c, u, e) => const Icon(Icons.error));
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: Colors.grey[400]), const SizedBox(height: 8), Text('Adicionar Logo', style: TextStyle(color: Colors.grey[400]))]);
  }
}