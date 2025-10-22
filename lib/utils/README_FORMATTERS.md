# Formatadores e Validadores

Este documento explica como usar os formatadores e validadores implementados no aplicativo.

## 📋 **Formatadores Disponíveis**

### 1. **CPF** - `Formatters.cpf`
```dart
// Máscara: 000.000.000-00
FormattedTextField(
  controller: cpfController,
  formatter: Formatters.cpf,
  validator: Validators.cpf,
)
```

### 2. **Telefone** - `Formatters.phone`
```dart
// Máscara: (00) 00000-0000
FormattedTextField(
  controller: phoneController,
  formatter: Formatters.phone,
  validator: Validators.phone,
)
```

### 3. **Telefone Fixo** - `Formatters.phoneFixed`
```dart
// Máscara: (00) 0000-0000
FormattedTextField(
  controller: phoneController,
  formatter: Formatters.phoneFixed,
  validator: Validators.phone,
)
```

### 4. **Data** - `Formatters.date`
```dart
// Máscara: 00/00/0000
FormattedTextField(
  controller: dateController,
  formatter: Formatters.date,
  validator: Validators.birthDate,
)
```

### 5. **CEP** - `Formatters.cep`
```dart
// Máscara: 00000-000
FormattedTextField(
  controller: cepController,
  formatter: Formatters.cep,
  validator: Validators.cep,
)
```

### 6. **RG** - `Formatters.rg`
```dart
// Máscara: 00.000.000-0
FormattedTextField(
  controller: rgController,
  formatter: Formatters.rg,
  validator: Validators.rg,
)
```

### 7. **CNPJ** - `Formatters.cnpj`
```dart
// Máscara: 00.000.000/0000-00
FormattedTextField(
  controller: cnpjController,
  formatter: Formatters.cnpj,
  validator: Validators.cnpj,
)
```

## 🔍 **Validadores Disponíveis**

### 1. **CPF** - `Validators.cpf`
- Valida formato (11 dígitos)
- Valida algoritmo do CPF
- Rejeita CPFs com todos os dígitos iguais

### 2. **Telefone** - `Validators.phone`
- Valida formato (10 ou 11 dígitos)
- Valida DDD (deve começar com 1-9)

### 3. **Data de Nascimento** - `Validators.birthDate`
- Valida formato (DD/MM/AAAA)
- Valida se a data é real
- Valida idade mínima (16 anos) e máxima (100 anos)
- Rejeita datas futuras

### 4. **CEP** - `Validators.cep`
- Valida formato (8 dígitos)

### 5. **RG** - `Validators.rg`
- Valida formato (7 a 9 dígitos)

### 6. **CNPJ** - `Validators.cnpj`
- Valida formato (14 dígitos)
- Valida algoritmo do CNPJ
- Rejeita CNPJs com todos os dígitos iguais

### 7. **Email** - `Validators.email`
- Valida formato de email

### 8. **Nome** - `Validators.name`
- Valida tamanho (2-100 caracteres)
- Valida se contém apenas letras e espaços

### 9. **Endereço** - `Validators.address`
- Valida tamanho (5-200 caracteres)

## 🎯 **Widgets Específicos**

### 1. **CPFField**
```dart
CPFField(
  controller: cpfController,
  onChanged: (value) {
    // Lógica adicional
  },
)
```

### 2. **PhoneField**
```dart
PhoneField(
  controller: phoneController,
  isFixed: false, // true para telefone fixo
  onChanged: (value) {
    // Lógica adicional
  },
)
```

### 3. **BirthDateField**
```dart
BirthDateField(
  controller: birthDateController,
  onChanged: (value) {
    // Lógica adicional
  },
)
```

### 4. **EmailField**
```dart
EmailField(
  controller: emailController,
  onChanged: (value) {
    // Lógica adicional
  },
)
```

### 5. **NameField**
```dart
NameField(
  controller: nameController,
  labelText: 'Nome Completo',
  onChanged: (value) {
    // Lógica adicional
  },
)
```

## 🗺️ **Seletor de Endereço com Google Maps**

### **AddressPickerWidget**
```dart
AddressPickerWidget(
  initialAddress: 'Endereço inicial',
  initialLocation: locationData,
  labelText: 'Endereço Completo',
  hintText: 'Digite o endereço...',
  isRequired: true,
  onAddressSelected: (address, location) {
    setState(() {
      _address = address;
      _location = location;
    });
  },
)
```

**Funcionalidades:**
- Busca de endereços por texto
- Mapa interativo do Google Maps
- Seleção por toque no mapa
- Obtenção da localização atual
- Validação de endereço

## 📍 **Serviço de CEP**

### **CEPService**
```dart
// Buscar endereço pelo CEP
final address = await CEPService.getAddressByCEP('12345678');

// Validar CEP
bool isValid = CEPService.isValidCEP('12345-678');

// Formatar CEP
String formatted = CEPService.formatCEP('12345678'); // 12345-678
```

## 🔧 **Exemplo de Uso Completo**

```dart
class MyFormPage extends StatefulWidget {
  @override
  _MyFormPageState createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();

  LocationData? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Nome
            NameField(controller: _nameController),
            
            // CPF
            CPFField(controller: _cpfController),
            
            // Telefone
            PhoneField(controller: _phoneController),
            
            // Data de Nascimento
            BirthDateField(controller: _birthDateController),
            
            // CEP
            CEPField(
              controller: _cepController,
              onChanged: (value) {
                if (value.length == 9) {
                  _searchAddressByCEP(value);
                }
              },
            ),
            
            // Endereço com Google Maps
            AddressPickerWidget(
              initialAddress: _addressController.text,
              initialLocation: _selectedLocation,
              onAddressSelected: (address, location) {
                setState(() {
                  _addressController.text = address;
                  _selectedLocation = location;
                });
              },
            ),
            
            // Botão de salvar
            ElevatedButton(
              onPressed: _saveForm,
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchAddressByCEP(String cep) async {
    try {
      final address = await CEPService.getAddressByCEP(cep);
      if (address != null) {
        setState(() {
          _addressController.text = address.formattedAddress;
          _selectedLocation = address;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar CEP: $e')),
      );
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Salvar dados
      print('Formulário válido!');
    }
  }
}
```

## 🚀 **Integração com APIs**

### **ViaCEP**
- Busca automática de endereço pelo CEP
- Integração com `CEPService.getAddressByCEP()`

### **Google Maps**
- Busca de endereços por texto
- Obtenção de coordenadas
- Validação de localização

## 📱 **Características dos Formatadores**

1. **Aplicação Automática**: As máscaras são aplicadas automaticamente durante a digitação
2. **Validação em Tempo Real**: Os validadores verificam o formato conforme o usuário digita
3. **Feedback Visual**: Mensagens de erro claras e específicas
4. **Compatibilidade**: Funciona com todos os tipos de teclado
5. **Acessibilidade**: Suporte completo a leitores de tela

## 🎨 **Personalização**

### **Cores e Estilos**
```dart
FormattedTextField(
  controller: controller,
  decoration: KInputDecoration.textFieldDecoration(
    labelText: 'Campo Personalizado',
    // Personalize cores, bordas, etc.
  ),
)
```

### **Validações Customizadas**
```dart
FormattedTextField(
  controller: controller,
  validator: (value) {
    // Sua validação customizada
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    // Outras validações...
    return null;
  },
)
```

## 🔒 **Segurança**

- **Validação Client-Side**: Validação imediata no dispositivo
- **Validação Server-Side**: Sempre valide novamente no servidor
- **Sanitização**: Os formatadores removem caracteres inválidos automaticamente
- **Máscaras Consistentes**: Garantem formato uniforme em todos os dispositivos

## 📊 **Performance**

- **Lazy Loading**: As máscaras são aplicadas apenas quando necessário
- **Validação Otimizada**: Algoritmos eficientes para validação
- **Cache de Endereços**: Endereços buscados são armazenados temporariamente
- **Debounce**: Evita muitas requisições durante a digitação

## 🐛 **Solução de Problemas**

### **Máscara não aplica**
- Verifique se o `formatter` está correto
- Confirme se o `TextInputType` está adequado

### **Validação falha**
- Verifique se o `validator` está sendo usado
- Confirme se os dados estão no formato esperado

### **Google Maps não carrega**
- Verifique se a API key está configurada
- Confirme se as permissões estão corretas

### **CEP não encontrado**
- Verifique se o CEP está no formato correto
- Confirme se a conexão com a internet está ativa
