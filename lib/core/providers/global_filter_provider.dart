import 'package:flutter_riverpod/flutter_riverpod.dart';
    import '../models/category_model.dart';

    // Este provider armazena o objeto da Categoria selecionada (ou null se for "Todas")
    final selectedCategoryProvider = StateProvider<Category?>((ref) {
      return null; // O valor inicial é null, que representará "Todas as Categorias"
    });