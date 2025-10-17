  import 'package:flutter/material.dart';


    const Color primaryColor = Color(0xFFF3B61F); // Ouro para texto, ícones e destaques
    const Color brandingRed = Color(0xFF800000); // Vermelho escuro/vinho da marca (para fundos)
    const Color darkBackground = Color(0xFF2A0808);  // Fundo principal (marrom muito escuro)
    const Color darkBackgroundColor = Color(0xFF800000); // Vermelho escuro/vinho da marca
    const Color cardColor = Color(0xFF1E1E1E); // Cor para cards e superfícies
    const Color textOnGold = Colors.black;

    final appTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      primaryColor: primaryColor,

  // Esquema de cores moderno (Material 3)
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,
    secondary: brandingRed,
    surface: cardColor,
    onPrimary: textOnGold, // <-- MUDANÇA: Texto sobre a cor primária (botões) será preto
    onSecondary: Colors.white,
    onSurface: Colors.white,
  ),

  // Tema para a AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: cardColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),

  // Tema para Botões Elevados
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor, // Fundo do botão (dourado)
      foregroundColor: textOnGold, // <-- MUDANÇA: Cor do texto do botão (preto)
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),

  // Tema para Campos de Texto
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: cardColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    floatingLabelStyle: const TextStyle(color: primaryColor),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
  ),

  // Tema para ListTile
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    tileColor: cardColor,
  ),
);