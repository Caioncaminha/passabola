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
passabola/
├── lib/                        # Código principal Flutter/Dart
│   ├── core/                   # Utilitários, rotas, helpers globais
│   ├── models/                 # Modelos de dados
│   ├── providers/              # Gerenciamento de estado
│   ├── screens/                # Telas/views organizadas por domínio
│   ├── services/               # Serviços (API, Auth, Firestore, etc)
│   └── widgets/                # Componentes reutilizáveis
│
├── functions/                  # Backend Node.js (Firebase Functions)
│   ├── src/                    # Código fonte das funções
│   ├── tests/                  # Testes das funções
│   ├── package.json
│   └── .eslintrc.js
│
├── dataconnect/                # Configurações GraphQL, seeds, schemas
│   ├── schema/                 # Schemas GraphQL
│   ├── example/                # Exemplos de uso
│   └── seed_data.gql           # Dados de seed
│
├── dataconnect-generated/      # Código gerado automaticamente
│   └── dart/                   # Código gerado para Dart
│
├── public/                     # Arquivos estáticos (web)
│   └── index.html
│
├── android/                    # Projeto Android nativo
├── ios/                        # Projeto iOS nativo
├── test/                       # Testes unitários Flutter/Dart
├── .gitignore
├── pubspec.yaml
├── README.md
├── firestore.rules
├── firestore.indexes.json
├── analysis_options.yaml


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
