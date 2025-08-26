# Guia de Constantes - Passa a Bola

Este documento explica como usar as constantes criadas para manter consistência visual em todo o aplicativo.

## 📁 Estrutura dos Arquivos

- `constants.dart` - Arquivo principal com todas as constantes
- `constants_examples.dart` - Exemplos de uso das constantes
- `README_CONSTANTS.md` - Este arquivo de documentação

## 🎨 Constantes de Cores (KConstants)

### Cores Principais
```dart
KConstants.primaryColor      // #5e3b63 - Roxo escuro (Cor principal)
KConstants.secondaryColor    // #a74e67 - Rosa avermelhado (Cor secundária)
KConstants.backgroundColor   // #598819 - Verde escuro (Cor de fundo)
KConstants.surfaceColor      // Cinza - Cor de superfície
```

### Cores de Estado
```dart
KConstants.errorColor        // Vermelho - Para erros
KConstants.successColor      // Verde - Para sucessos
KConstants.warningColor      // Laranja - Para avisos
KConstants.infoColor         // Azul - Para informações
```

### Cores de Texto
```dart
KConstants.textPrimaryColor    // Preto 87% - Texto principal
KConstants.textSecondaryColor  // Preto 54% - Texto secundário
KConstants.textTertiaryColor   // Preto 38% - Texto terciário
KConstants.textLightColor      // Branco - Texto claro
```

## 📏 Tamanhos e Espaçamentos

### Tamanhos de Fonte
```dart
KConstants.fontSizeExtraSmall        // 10.0
KConstants.fontSizeSmall             // 12.0
KConstants.fontSizeMedium            // 14.0
KConstants.fontSizeLarge             // 16.0
KConstants.fontSizeExtraLarge        // 18.0
KConstants.fontSizeTitle             // 20.0
KConstants.fontSizeSubtitle          // 22.0
KConstants.fontSizeHeading           // 24.0
KConstants.fontSizeLargeHeading      // 28.0
KConstants.fontSizeExtraLargeHeading // 32.0
```

### Espaçamentos
```dart
KConstants.spacingExtraSmall  // 4.0
KConstants.spacingSmall       // 8.0
KConstants.spacingMedium      // 16.0
KConstants.spacingLarge       // 24.0
KConstants.spacingExtraLarge  // 32.0
```

### Bordas
```dart
KConstants.borderRadiusSmall       // 4.0
KConstants.borderRadiusMedium      // 8.0
KConstants.borderRadiusLarge       // 12.0
KConstants.borderRadiusExtraLarge  // 16.0
```

## 📝 Estilos de Texto (KTextStyle)

### Títulos
```dart
KTextStyle.titleTealText        // Título roxo, 18px, bold
KTextStyle.titleText            // Título normal, 20px, bold
KTextStyle.largeTitleText       // Título grande, 24px, bold
KTextStyle.extraLargeTitleText  // Título extra grande, 28px, bold
```

### Subtítulos
```dart
KTextStyle.subtitleText         // Subtítulo normal, 22px, w600
KTextStyle.subtitleTealText     // Subtítulo roxo, 22px, w600
```

### Descrições
```dart
KTextStyle.descriptionText           // Descrição principal, 16px
KTextStyle.descriptionSecondaryText  // Descrição secundária, 16px
```

### Textos de Corpo
```dart
KTextStyle.bodyText              // Texto de corpo, 14px
KTextStyle.bodySecondaryText     // Texto de corpo secundário, 14px
```

### Textos Pequenos
```dart
KTextStyle.smallText             // Texto pequeno, 12px
KTextStyle.captionText           // Texto caption, 10px
```

### Textos de Botões
```dart
KTextStyle.buttonText            // Texto de botão, 14px, w600, branco
KTextStyle.buttonTextPrimary     // Texto de botão primário, 14px, w600, roxo
```

### Textos de Navegação
```dart
KTextStyle.navigationText        // Texto de navegação, 14px, w500
KTextStyle.navigationActiveText  // Texto de navegação ativo, 14px, w600, roxo
```

### Textos de Estado
```dart
KTextStyle.errorText             // Texto de erro, 14px, w500, vermelho
KTextStyle.successText           // Texto de sucesso, 14px, w500, verde
KTextStyle.warningText           // Texto de aviso, 14px, w500, laranja
KTextStyle.infoText              // Texto de informação, 14px, w500, azul
```

### Textos de Input
```dart
KTextStyle.inputText             // Texto de input, 14px
KTextStyle.inputLabelText        // Label de input, 12px, w500
KTextStyle.inputHintText         // Hint de input, 14px
```

### Textos de Card
```dart
KTextStyle.cardTitleText         // Título de card, 16px, w600
KTextStyle.cardSubtitleText      // Subtítulo de card, 14px
KTextStyle.cardBodyText          // Corpo de card, 14px
```

## 🎨 Decorações (KDecoration)

### Containers e Cards
```dart
KDecoration.primaryContainerDecoration  // Container com sombra suave
KDecoration.cardDecoration             // Card com sombra média
KDecoration.inputDecoration            // Decoração de input
KDecoration.buttonDecoration           // Decoração de botão
KDecoration.outlineButtonDecoration    // Decoração de botão outline
```

## 📝 Decorações de Input (KInputDecoration)

### Método Principal
```dart
KInputDecoration.textFieldDecoration({
  String? hintText,      // Texto de dica
  String? labelText,     // Texto do label
  IconData? prefixIcon,  // Ícone prefixo
  IconData? suffixIcon,  // Ícone sufixo
})
```

### Exemplos de Uso
```dart
// Campo simples
TextField(
  decoration: KInputDecoration.textFieldDecoration(
    hintText: 'Digite seu nome...',
  ),
)

// Campo com label e ícone
TextField(
  decoration: KInputDecoration.textFieldDecoration(
    labelText: 'Email',
    hintText: 'Digite seu email...',
    prefixIcon: Icons.email,
  ),
)

// Campo de pesquisa
TextField(
  decoration: KInputDecoration.textFieldDecoration(
    hintText: 'Pesquisar...',
    prefixIcon: Icons.search,
  ),
)
```

## 🚀 Exemplos Práticos

### 1. Criando um Card
```dart
Container(
  decoration: KDecoration.cardDecoration,
  padding: EdgeInsets.all(KConstants.spacingMedium),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Título do Card', style: KTextStyle.cardTitleText),
      SizedBox(height: KConstants.spacingSmall),
      Text('Descrição do card', style: KTextStyle.cardBodyText),
    ],
  ),
)
```

### 2. Criando um Botão
```dart
Container(
  decoration: KDecoration.buttonDecoration,
  padding: EdgeInsets.symmetric(
    horizontal: KConstants.spacingLarge,
    vertical: KConstants.spacingMedium,
  ),
  child: Text('Botão', style: KTextStyle.buttonText),
)
```

### 3. Criando um Campo de Texto
```dart
TextField(
  style: KTextStyle.inputText,
  decoration: KInputDecoration.textFieldDecoration(
    labelText: 'Nome',
    hintText: 'Digite seu nome completo',
    prefixIcon: Icons.person,
  ),
)
```

### 4. Criando uma Lista
```dart
ListView.builder(
  padding: EdgeInsets.all(KConstants.spacingMedium),
  itemBuilder: (context, index) {
    return Padding(
      padding: EdgeInsets.only(bottom: KConstants.spacingSmall),
      child: Text('Item $index', style: KTextStyle.bodyText),
    );
  },
)
```

## 💡 Dicas de Uso

1. **Sempre use as constantes** em vez de valores hardcoded
2. **Combine estilos** usando `.copyWith()` para variações
3. **Mantenha consistência** usando os mesmos estilos em elementos similares
4. **Use os espaçamentos** para manter alinhamento consistente
5. **Prefira as decorações** prontas para inputs e containers

## 🔄 Modificando Estilos

Para criar variações de estilos existentes:

```dart
// Modificar cor
Text('Texto', style: KTextStyle.bodyText.copyWith(color: Colors.red))

// Modificar tamanho
Text('Texto', style: KTextStyle.bodyText.copyWith(fontSize: 18))

// Modificar peso
Text('Texto', style: KTextStyle.bodyText.copyWith(fontWeight: FontWeight.bold))

// Múltiplas modificações
Text('Texto', style: KTextStyle.bodyText.copyWith(
  color: Colors.blue,
  fontSize: 16,
  fontWeight: FontWeight.w600,
))
```

## 📱 Responsividade

As constantes foram criadas pensando em diferentes tamanhos de tela. Para ajustes específicos:

```dart
// Usar MediaQuery para ajustes responsivos
double screenWidth = MediaQuery.of(context).size.width;
double fontSize = screenWidth > 600 ? 18.0 : KConstants.fontSizeMedium;

Text('Texto Responsivo', style: KTextStyle.bodyText.copyWith(fontSize: fontSize))
```
