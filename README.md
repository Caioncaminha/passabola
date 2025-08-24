# ⚽ Passa a Bola – Aplicativo de Apoio ao Futebol Feminino

O **Passa a Bola** é um aplicativo desenvolvido em **Flutter** com foco no fortalecimento do futebol feminino.  
A proposta é fornecer uma plataforma digital que dê **visibilidade às atletas**, ofereça **estatísticas em tempo real** e crie um **espaço de engajamento para fãs, clubes e jogadoras**.

---

## 🚀 Objetivos do Projeto

- Aumentar a **visibilidade midiática** do futebol feminino.
- Criar um **hub de informações centralizado**, com dados confiáveis e organizados.
- Desenvolver funcionalidades que gerem **engajamento entre fãs e atletas**.
- Apoiar clubes, jogadoras e torcedores com **ferramentas tecnológicas acessíveis**.

---

## 🛠️ Tecnologias Utilizadas

- **Frontend:** Flutter (Dart)
- **Backend/Banco:** Firebase Firestore + Authentication
- ...

---

## 📱 Funcionalidades Planejadas

- Cadastro e login de usuários (torcedores, atletas, clubes, administradores).
- Página inicial com **feed de conteúdo**.
- Perfis de atletas com **estatísticas, histórico e bio**.
- ...

---

## 📂 Estrutura de Pastas (Flutter)

```
passa_a_bola/
│
├── android/                     # Configurações nativas Android
├── ios/                         # Configurações nativas iOS
├── web/                         # Suporte para versão web (opcional)
├── test/                        # Testes unitários e widget tests
│
├── assets/                      # Recursos estáticos
│   ├── images/                  # Logos, ícones, fotos
│   ├── icons/                   # Ícones customizados
│   └── fonts/                   # Fontes personalizadas
│
├── lib/                         # Código principal do app
│   ├── main.dart                 # Ponto de entrada do app
│   │
│   ├── core/                     # Configurações centrais
│   │   ├── constants/            # Constantes globais (cores, textos fixos)
│   │   ├── themes/               # Temas (light, dark, estilos visuais)
│   │   ├── utils/                # Funções auxiliares (formatadores, validadores)
│   │   └── routes.dart           # Definição das rotas de navegação
│   │
│   ├── models/                   # Modelos de dados (Usuario, Atleta, Clube, Partida)
│   │   └── atleta.dart
│   │
│   ├── services/                 # Serviços (Firebase, APIs, autenticação)
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── notification_service.dart
│   │
│   ├── repositories/             # Camada de acesso a dados
│   │   ├── usuario_repository.dart
│   │   ├── atleta_repository.dart
│   │   └── clube_repository.dart
│   │
│   ├── controllers/              # Controladores (estado do app / lógica)
│   │   ├── auth_controller.dart
│   │   └── atleta_controller.dart
│   │
│   ├── screens/                  # Telas do aplicativo
│   │   ├── auth/                 # Telas de login e cadastro
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/                 # Tela inicial
│   │   │   └── home_screen.dart
│   │   ├── atleta/               # Perfil de atletas
│   │   │   └── atleta_screen.dart
│   │   ├── clube/                # Perfil de clubes
│   │   │   └── clube_screen.dart
│   │   ├── partida/              # Estatísticas de partidas
│   │   │   └── partida_screen.dart
│   │   └── settings/             # Configurações
│   │       └── settings_screen.dart
│   │
│   ├── widgets/                  # Componentes reutilizáveis
│   │   ├── custom_button.dart
│   │   ├── custom_card.dart
│   │   └── input_field.dart
│   │
│   └── providers/                # Gerência de estado (Provider, Riverpod, Bloc)
│       └── app_state.dart
│
├── pubspec.yaml                  # Configurações do Flutter (dependências, assets, fonts)
├── analysis_options.yaml          # Regras de lint e boas práticas
└── README.md                     # Documentação do projeto


```

---

## 👨‍💻 Equipe de Desenvolvimento

- Caio Nascimento Caminha
- Gabriel Alexandre Fukushima Sakura
- Gabriel Oliveira Amaral
- Lucas Henrique Viana Estevam Sena
- Rafael Tavares Santos

---

## 📖 Licença

Este projeto é desenvolvido para fins acadêmicos, dentro do curso de Engenharia de Software, e poderá ser expandido futuramente para produção.
