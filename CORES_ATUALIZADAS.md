# Atualização de Cores - Passa a Bola

## 🎨 Novas Cores Implementadas

As cores do aplicativo foram atualizadas conforme solicitado:

### Cores Principais
- **Cor Primária**: `#5e3b63` (Roxo escuro)
- **Cor Secundária**: `#a74e67` (Rosa avermelhado)  
- **Cor de Fundo**: `#598819` (Verde escuro)

### Implementação

#### 1. Arquivo `lib/data/constants.dart`
```dart
// Cores principais
static const Color primaryColor = Color(0xFF5e3b63);    // Roxo escuro
static const Color secondaryColor = Color(0xFFa74e67);  // Rosa avermelhado
static const Color backgroundColor = Color(0xFF598819); // Verde escuro
```

#### 2. Arquivo `lib/main.dart`
```dart
theme: ThemeData(
  primarySwatch: Colors.deepPurple,
  primaryColor: KConstants.primaryColor,
  scaffoldBackgroundColor: KConstants.backgroundColor,
  // ... resto do tema
)
```

## 🔄 Mudanças Aplicadas

### ✅ Arquivos Modificados:
1. **`lib/data/constants.dart`** - Cores principais atualizadas
2. **`lib/main.dart`** - Tema do aplicativo atualizado
3. **`lib/data/README_CONSTANTS.md`** - Documentação atualizada

### 🎯 Impacto Visual:

#### Antes:
- Cor primária: Teal (azul-esverdeado)
- Cor secundária: TealAccent (azul-esverdeado claro)
- Cor de fundo: Branco

#### Depois:
- Cor primária: Roxo escuro (#5e3b63)
- Cor secundária: Rosa avermelhado (#a74e67)
- Cor de fundo: Verde escuro (#598819)

## 📱 Elementos Afetados

### AppBar
- Cor de fundo: Roxo escuro (#5e3b63)
- Texto e ícones: Branco

### Navegação Inferior
- Cor de fundo: Roxo escuro (#5e3b63)
- Item selecionado: Verde (sucesso)
- Itens não selecionados: Branco

### Páginas
- Cor de fundo: Verde escuro (#598819)
- Elementos de destaque: Rosa avermelhado (#a74e67)

### Campos de Texto
- Bordas: Roxo escuro (#5e3b63) quando focado
- Fundo: Branco

## 🎨 Paleta de Cores Completa

```
Primária:     #5e3b63 (Roxo escuro)
Secundária:   #a74e67 (Rosa avermelhado)
Fundo:        #598819 (Verde escuro)
Superfície:   Cinza
Erro:         Vermelho
Sucesso:      Verde
Aviso:        Laranja
Informação:   Azul
```

## 💡 Como Usar as Novas Cores

### Em código:
```dart
// Usar cor primária
Container(color: KConstants.primaryColor)

// Usar cor secundária
Container(color: KConstants.secondaryColor)

// Usar cor de fundo
Scaffold(backgroundColor: KConstants.backgroundColor)
```

### Em estilos de texto:
```dart
// Texto com cor primária
Text('Título', style: KTextStyle.titleTealText)

// Texto com cor secundária
Text('Subtítulo', style: KTextStyle.subtitleText.copyWith(
  color: KConstants.secondaryColor
))
```

## ✅ Verificação

- ✅ Flutter analyze executado sem erros
- ✅ Todas as constantes atualizadas
- ✅ Documentação atualizada
- ✅ Tema do aplicativo configurado
- ✅ Cores aplicadas em todos os componentes

## 🚀 Próximos Passos

As novas cores estão ativas e serão aplicadas automaticamente em:
- AppBar
- Navegação inferior
- Campos de texto
- Botões
- Cards e containers
- Todos os elementos que usam as constantes

Para ver as mudanças, execute o aplicativo:
```bash
flutter run
```
