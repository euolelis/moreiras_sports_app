# Moreira's Sports App

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange.svg)
![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-blueviolet.svg)

Aplicativo piloto de gestão para a escola de futebol Moreira's Sports. Este projeto serve como um protótipo funcional para uma futura plataforma SaaS white-label, projetada para ser adaptável a qualquer clube ou escola de futebol.

## 📸 Screenshots

*(Substitua estas imagens por capturas de tela reais do seu aplicativo)*

| Splash Screen | Tela de Entrada | Seleção de Categoria |
| :-----------: | :-------------: | :------------------: |
| ![Splash Screen](https://via.placeholder.com/300x650/8B0000/FFFFFF?text=Splash+Screen) | ![Landing Screen](https://via.placeholder.com/300x650/1a1a1a/FFFFFF?text=Landing+Screen) | ![Category Selection](https://via.placeholder.com/300x650/1a1a1a/FFFFFF?text=Category+Selection) |
| **Home Page** | **Detalhes do Jogador** | **Painel do Admin** |
| ![Home Page](https://via.placeholder.com/300x650/1a1a1a/FFFFFF?text=Home+Page) | ![Player Detail](https://via.placeholder.com/300x650/1a1a1a/FFFFFF?text=Player+Detail) | ![Admin Dashboard](https://via.placeholder.com/300x650/1a1a1a/FFFFFF?text=Admin+Dashboard) |

---

## ✅ Funcionalidades Implementadas

### Área Pública (Visitante)
- [x] **Fluxo de Entrada Completo:** Splash Screen -> Tela de Entrada (Landing) -> Seleção de Categoria.
- [x] **Filtro Global por Categoria:** A seleção de categoria na tela inicial filtra o conteúdo em todo o aplicativo (Elenco, Jogos, Estatísticas, Patrocinadores).
- [x] **Home Screen:** Painel de navegação principal com layout em grade e `AppBar` dinâmica que exibe a categoria selecionada.
- [x] **Elenco:** Lista de jogadores agrupados por categoria usando painéis expansíveis (`ExpansionTile`).
- [x] **Detalhes do Jogador:** Tela de perfil completa com foto, informações pessoais, estatísticas de desempenho e link para redes sociais.
- [x] **Calendário de Jogos:** Lista de jogos passados e futuros, filtrada por categoria.
- [x] **Detalhes do Jogo:** Tela com informações da partida e timeline de eventos (gols, cartões, etc.).
- [x] **Estatísticas:** Tela com abas para rankings de Artilharia, Assistências e Cartões, filtrados por categoria.
- [x] **Notícias:** Lista de notícias do clube.
- [x] **Patrocinadores:** Lista de patrocinadores com logo e nome, filtrada por categoria, com navegação para tela de detalhes.
- [x] **Sobre o Clube:** Página de informações estáticas acessível pela `AppBar` e `BottomNavigationBar`.
- [x] **Navegação Centralizada:** `MainScaffold` com `AppBar` e `BottomNavigationBar` consistentes em todas as telas principais.

### Área Administrativa (Admin)
- [x] **Autenticação:** Login de administrador com e-mail e senha via Firebase Auth.
- [x] **Rotas Protegidas:** Acesso ao painel `/admin` restrito a usuários autenticados.
- [x] **Painel de Controle:** Dashboard com acesso a todas as seções de gerenciamento.
- [x] **CRUD de Jogadores:** Adicionar, editar e excluir jogadores, com upload de fotos e edição de todas as estatísticas.
- [x] **CRUD de Categorias:** Adicionar, editar e excluir categorias de times.
- [x] **CRUD de Jogos:** Adicionar e editar informações de jogos (adversário, local, data, etc.).
- [x] **CRUD de Notícias:** Adicionar, editar e excluir notícias, com upload de imagem de capa.
- [x] **CRUD de Patrocinadores:** Adicionar, editar e excluir patrocinadores, com upload de logo.
- [x] **Gerenciamento de Partidas:** Tela de detalhes do jogo para lançar eventos em tempo real (gols, assistências, cartões) e atualizar o placar final.
- [x] **Feedback ao Usuário:** Mensagens de sucesso (`SnackBar`) após salvar ou editar dados.
- [x] **Segurança:** Diálogos de confirmação para todas as ações de exclusão.

### Geral e Técnico
- [x] **Tema Customizado:** Tema escuro (`dark theme`) consistente em todo o aplicativo.
- [x] **Gerenciamento de Estado:** Utilização de Riverpod para um gerenciamento de estado reativo e escalável.
- [x] **Navegação:** Roteamento robusto e declarativo com GoRouter, suportando rotas aninhadas e passagem de parâmetros.
- [x] **Backend:** Integração completa com Firebase (Authentication, Firestore, Storage).
- [x] **Suporte Multiplataforma:** Lógica de upload de imagem compatível com Web e Mobile.
- [x] **Localização:** Configuração para `pt_BR`, garantindo que widgets nativos (como `DatePicker`) apareçam em português.

---

## 🚀 Stack de Tecnologias

- **Framework:** Flutter
- **Linguagem:** Dart
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **Gerenciamento de Estado:** Riverpod
- **Navegação:** GoRouter
- **UI & Utilitários:**
  - `cached_network_image`: Para exibição e cache de imagens da internet.
  - `image_picker`: Para seleção de imagens da galeria/câmera.
  - `url_launcher`: Para abrir links externos (redes sociais, sites).
  - `intl`: Para formatação de datas.
  - `lottie`: Para animações (usado na Splash Screen).
  - `flutter_localizations`: Para internacionalização.

---

## 📂 Estrutura do Projeto

O projeto segue uma arquitetura limpa, separando as responsabilidades em camadas:

```
lib/
├── core/
│   ├── models/         # Modelos de dados (Player, Game, etc.)
│   ├── services/       # Serviços de backend (Firestore, Auth, Storage)
│   └── providers/      # Providers globais (ex: filtro de categoria)
├── features/
│   ├── admin/          # Telas e widgets da área administrativa
│   ├── auth/           # Telas de autenticação (Login, Landing)
│   ├── home/           # Tela principal e de seleção de categoria
│   └── ...             # Outras features (players, games, news, etc.)
├── navigation/
│   └── app_router.dart # Configuração centralizada do GoRouter
└── shared/
    ├── theme/          # Tema do aplicativo (cores, fontes)
    └── widgets/        # Widgets reutilizáveis (MainScaffold, Dialogs)
```

---

## 📋 Checklist Técnico: Controle de Versão e Documentação (Git)

Este checklist serve para garantir as boas práticas de versionamento e documentação do projeto.

- [x] **Repositório no GitHub:** O projeto está versionado em um repositório Git remoto.
- [x] **Commits Semânticos:** As mensagens de commit seguem um padrão para facilitar a leitura do histórico (ex: `feat:`, `fix:`, `refactor:`, `docs:`).
- [ ] **Estratégia de Branches:** Adotar uma estratégia como Git Flow (`main`, `develop`, `feature/nome-da-feature`) para organizar o desenvolvimento de novas funcionalidades e correções.
- [x] **README.md Detalhado:** Este documento existe e está atualizado com as informações essenciais do projeto.
- [x] **`.gitignore` Configurado:** O arquivo `.gitignore` padrão do Flutter está em uso para evitar o versionamento de arquivos gerados e sensíveis.
