# Moreira's Sports App (Projeto Piloto)
 <!-- TODO: Substitua pela URL de uma imagem do logo -->

## 📖 Sobre o Projeto

Este é o repositório do aplicativo móvel **Moreira's Sports**, o projeto piloto para uma plataforma white-label (SaaS) destinada a escolas de futebol e clubes esportivos amadores. O objetivo é centralizar a comunicação, gestão de elenco, calendário de jogos e estatísticas, profissionalizando a operação do clube e aumentando o engajamento de pais e atletas.

O aplicativo está sendo desenvolvido em **Flutter** com **Firebase** como backend, garantindo uma experiência multiplataforma (iOS e Android) a partir de um único código-base.

---

## ✨ Funcionalidades Implementadas (Status Atual)

O projeto está em desenvolvimento ativo. As seguintes funcionalidades já foram implementadas e testadas:

### 👤 Perfil de Administrador
- [x] **Autenticação Segura:** Sistema de login e logout com Firebase Auth.
- [x] **Painel de Controle:** Dashboard centralizado para gerenciamento.
- [x] **Gestão de Categorias (CRUD):**
  - [x] Criar, visualizar e deletar categorias (ex: Sub-8, Sub-11).
- [x] **Gestão de Elenco (CRUD):**
  - [x] Criar, visualizar e editar jogadores.
  - [x] Associar cada jogador a uma categoria específica.
  - [x] Fazer upload de foto de perfil para cada jogador.
- [x] **Gestão de Calendário (CRUD):**
  - [x] Agendar, visualizar e editar jogos (adversário, campeonato, data, local, status).
- [x] **Gestão de Estatísticas da Partida (CRUD):**
  - [x] Acessar detalhes de um jogo.
  - [x] Lançar eventos da partida (Gols, Assistências).
  - [x] Atualizar placar final.
  - [x] As estatísticas totais do jogador (gols, assistências) são atualizadas automaticamente.

### 👥 Perfil de Visitante (Público)
- [x] **Fluxo de Entrada:**
  - [x] Splash Screen na inicialização.
  - [x] Tela de seleção para entrar como "Visitante" ou "Admin".
- [x] **Navegação Principal:** Estrutura com `BottomNavigationBar` para as seções principais.
- [x] **Tela Home:** Menu principal com atalhos para as funcionalidades.
- [x] **Visualização de Elenco:**
  - [x] Listagem de jogadores.
  - [x] Tela de detalhes do jogador com foto, dados e estatísticas (layout avançado implementado).

---

## 🚀 Próximos Passos (Roadmap para v1.0)

- **[ ] Finalizar Fluxo de Jogos (Público):**
  - [ ] Criar tela para listar o calendário de jogos.
  - [ ] Criar tela de detalhes do jogo para exibir placar e timeline de eventos.
- **[ ] Implementar Estatísticas (Público):**
  - [ ] Criar tela de rankings (artilharia, assistências).
- **[ ] Implementar Notícias (CRUD Admin + Público):**
  - [ ] Finalizar o ciclo completo para o admin criar e o visitante ler notícias.
- **[ ] Implementar Patrocinadores (CRUD Admin + Público):**
  - [ ] Permitir que o admin cadastre patrocinadores com logo.
  - [ ] Exibir os logos em uma seção pública.
- **[ ] Polimento e Lançamento:**
  - [ ] Refinamento geral da UI/UX.
  - [ ] Geração dos ícones e assets finais.
  - [ ] Build de produção e publicação na Google Play Store.

---

## 🛠️ Tecnologias Utilizadas

*   **Framework:** [Flutter](https://flutter.dev/)
*   **Linguagem:** [Dart](https://dart.dev/)
*   **Backend & Database:** [Firebase](https://firebase.google.com/) (Firestore, Authentication, Storage)
*   **Gerenciamento de Estado:** [Riverpod](https://riverpod.dev/)
*   **Navegação:** [GoRouter](https://pub.dev/packages/go_router)

## ⚙️ Configuração do Ambiente de Desenvolvimento

Para rodar este projeto localmente, siga os passos abaixo:

1.  **Clone o repositório:**
    ```bash
    git clone [URL_DO_SEU_REPOSITORIO_PRIVADO]
    cd moreiras_sports_app
    ```

2.  **Instale as dependências do Flutter:**
    ```bash
    flutter pub get
    ```

3.  **Configuração do Firebase:**
    - Este projeto requer uma configuração do Firebase para funcionar.
    - Crie um projeto no [console do Firebase](https://console.firebase.google.com/).
    - Ative os serviços: **Authentication** (com provedor E-mail/Senha), **Firestore Database** e **Storage**.
    - Instale o Firebase CLI: `npm install -g firebase-tools`.
    - Faça login: `firebase login`.
    - Configure o projeto com o FlutterFire: `flutterfire configure`.
    - Selecione o projeto Firebase que você criou e as plataformas (android, ios). Isso irá gerar o arquivo `lib/firebase_options.dart`.

4.  **Crie um Usuário Admin:**
    - No console do Firebase, vá para **Authentication > Users** e crie um usuário com e-mail e senha para poder acessar o painel de administrador.

5.  **Rode o aplicativo:**
    ```bash
    flutter run
    ```

---

## 🤝 Contribuições

Este é um projeto privado. Para contribuições, por favor, entre em contato com o mantenedor do repositório.