import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Formatters {
  // Máscara para CPF: 000.000.000-00
  static final cpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para telefone: (00) 00000-0000
  static final phone = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para telefone fixo: (00) 0000-0000
  static final phoneFixed = MaskTextInputFormatter(
    mask: '(##) ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para data: 00/00/0000
  static final date = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para CEP: 00000-000
  static final cep = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para RG: 00.000.000-0
  static final rg = MaskTextInputFormatter(
    mask: '##.###.###-#',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para CNPJ: 00.000.000/0000-00
  static final cnpj = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para cartão de crédito: 0000 0000 0000 0000
  static final creditCard = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para CVV: 000
  static final cvv = MaskTextInputFormatter(
    mask: '###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Máscara para validade do cartão: 00/00
  static final cardExpiry = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
}

class Validators {
  // Valida CPF
  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }

    // Remove formatação
    String cpf = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Validação do algoritmo do CPF
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cpf[9]) != digit1) {
      return 'CPF inválido';
    }

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cpf[10]) != digit2) {
      return 'CPF inválido';
    }

    return null;
  }

  // Valida telefone
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }

    String phone = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.length < 10 || phone.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }

    // Verifica se é um número válido
    if (phone.length == 11 && !phone.startsWith(RegExp(r'[1-9]'))) {
      return 'DDD deve começar com dígito de 1 a 9';
    }

    return null;
  }

  // Valida data de nascimento
  static String? birthDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de nascimento é obrigatória';
    }

    String date = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (date.length != 8) {
      return 'Data deve ter 8 dígitos (DD/MM/AAAA)';
    }

    int day = int.parse(date.substring(0, 2));
    int month = int.parse(date.substring(2, 4));
    int year = int.parse(date.substring(4, 8));

    if (day < 1 || day > 31) {
      return 'Dia inválido';
    }

    if (month < 1 || month > 12) {
      return 'Mês inválido';
    }

    int currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      return 'Ano inválido';
    }

    // Verifica se a data é válida
    try {
      DateTime birthDate = DateTime(year, month, day);
      DateTime now = DateTime.now();

      if (birthDate.isAfter(now)) {
        return 'Data de nascimento não pode ser futura';
      }

      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      if (age < 16) {
        return 'Idade mínima é 16 anos';
      }

      if (age > 100) {
        return 'Idade máxima é 100 anos';
      }
    } catch (e) {
      return 'Data inválida';
    }

    return null;
  }

  // Valida CEP
  static String? cep(String? value) {
    if (value == null || value.isEmpty) {
      return 'CEP é obrigatório';
    }

    String cep = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }

    return null;
  }

  // Valida RG
  static String? rg(String? value) {
    if (value == null || value.isEmpty) {
      return 'RG é obrigatório';
    }

    String rg = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (rg.length < 7 || rg.length > 9) {
      return 'RG deve ter entre 7 e 9 dígitos';
    }

    return null;
  }

  // Valida CNPJ
  static String? cnpj(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNPJ é obrigatório';
    }

    String cnpj = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cnpj.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) {
      return 'CNPJ inválido';
    }

    // Validação do algoritmo do CNPJ
    List<int> weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    List<int> weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weights1[i];
    }
    int remainder = sum % 11;
    int digit1 = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cnpj[12]) != digit1) {
      return 'CNPJ inválido';
    }

    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weights2[i];
    }
    remainder = sum % 11;
    int digit2 = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cnpj[13]) != digit2) {
      return 'CNPJ inválido';
    }

    return null;
  }

  // Valida email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }

    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  // Valida nome
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }

    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }

    if (value.trim().length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }

    // Verifica se contém apenas letras e espaços
    String pattern = r'^[a-zA-ZÀ-ÿ\s]+$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(value.trim())) {
      return 'Nome deve conter apenas letras';
    }

    return null;
  }

  // Valida endereço
  static String? address(String? value) {
    if (value == null || value.isEmpty) {
      return 'Endereço é obrigatório';
    }

    if (value.trim().length < 5) {
      return 'Endereço deve ter pelo menos 5 caracteres';
    }

    if (value.trim().length > 200) {
      return 'Endereço deve ter no máximo 200 caracteres';
    }

    return null;
  }

  // Valida campo obrigatório genérico
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  // Valida tamanho mínimo
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    if (value.length < minLength) {
      return '$fieldName deve ter pelo menos $minLength caracteres';
    }

    return null;
  }

  // Valida tamanho máximo
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }

    if (value.length > maxLength) {
      return '$fieldName deve ter no máximo $maxLength caracteres';
    }

    return null;
  }
}
