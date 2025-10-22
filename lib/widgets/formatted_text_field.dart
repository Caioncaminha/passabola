import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../data/constants.dart';
import '../utils/formatters.dart';

class FormattedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final MaskTextInputFormatter? formatter;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const FormattedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.formatter,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: formatter != null ? [formatter!] : null,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      decoration: KInputDecoration.textFieldDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// Widgets específicos para cada tipo de campo

class CPFField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CPFField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedTextField(
      controller: controller,
      labelText: 'CPF',
      hintText: '000.000.000-00',
      prefixIcon: Icons.person,
      formatter: Formatters.cpf,
      validator: validator ?? Validators.cpf,
      keyboardType: TextInputType.number,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final bool isFixed;

  const PhoneField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.isFixed = false,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedTextField(
      controller: controller,
      labelText: 'Telefone',
      hintText: isFixed ? '(00) 0000-0000' : '(00) 00000-0000',
      prefixIcon: Icons.phone,
      formatter: isFixed ? Formatters.phoneFixed : Formatters.phone,
      validator: validator ?? Validators.phone,
      keyboardType: TextInputType.phone,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String labelText;

  const DateField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.labelText = 'Data',
  });

  @override
  Widget build(BuildContext context) {
    return FormattedTextField(
      controller: controller,
      labelText: labelText,
      hintText: '00/00/0000',
      prefixIcon: Icons.calendar_today,
      formatter: Formatters.date,
      validator: validator,
      keyboardType: TextInputType.number,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class BirthDateField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const BirthDateField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DateField(
      controller: controller,
      labelText: 'Data de Nascimento',
      validator: validator ?? Validators.birthDate,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class CEPField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CEPField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedTextField(
      controller: controller,
      labelText: 'CEP',
      hintText: '00000-000',
      prefixIcon: Icons.location_on,
      formatter: Formatters.cep,
      validator: validator ?? Validators.cep,
      keyboardType: TextInputType.number,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class RGField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const RGField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedTextField(
      controller: controller,
      labelText: 'RG',
      hintText: '00.000.000-0',
      prefixIcon: Icons.credit_card,
      formatter: Formatters.rg,
      validator: validator ?? Validators.rg,
      keyboardType: TextInputType.number,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class CNPJField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CNPJField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedTextField(
      controller: controller,
      labelText: 'CNPJ',
      hintText: '00.000.000/0000-00',
      prefixIcon: Icons.business,
      formatter: Formatters.cnpj,
      validator: validator ?? Validators.cnpj,
      keyboardType: TextInputType.number,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const EmailField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedTextField(
      controller: controller,
      labelText: 'Email',
      hintText: 'exemplo@email.com',
      prefixIcon: Icons.email,
      validator: validator ?? Validators.email,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String labelText;

  const NameField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.labelText = 'Nome',
  });

  @override
  Widget build(BuildContext context) {
    return FormattedTextField(
      controller: controller,
      labelText: labelText,
      hintText: 'Digite seu nome completo',
      prefixIcon: Icons.person,
      validator: validator ?? Validators.name,
      textCapitalization: TextCapitalization.words,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}
