import 'package:flutter/material.dart';

class KConstants {
  static const String themeModeKey = 'themeModeKey';

  // Cores principais
  static const Color lightGreenColor = Color(0xFF708F56); // verde claro
  static const Color primaryColor = Color(0xFF5e3b63); // Roxo escuro
  static const Color secondaryColor = Color(0xFFa74e67); // Rosa avermelhado
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.grey;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;

  // Cores de texto
  static const Color textPrimaryColor = Colors.black87;
  static const Color textSecondaryColor = Colors.black54;
  static const Color textTertiaryColor = Colors.black38;
  static const Color textLightColor = Colors.white;

  // Tamanhos de fonte
  static const double fontSizeExtraSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeSubtitle = 22.0;
  static const double fontSizeHeading = 24.0;
  static const double fontSizeLargeHeading = 28.0;
  static const double fontSizeExtraLargeHeading = 32.0;

  // Espaçamentos
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Bordas
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;
}

class KTextStyle {
  // Títulos principais
  static const TextStyle titleTealText = TextStyle(
    color: KConstants.primaryColor,
    fontSize: KConstants.fontSizeExtraLarge,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeTitle,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle largeTitleText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeHeading,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle extraLargeTitleText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeLargeHeading,
    fontWeight: FontWeight.bold,
  );

  // Subtítulos
  static const TextStyle subtitleText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeSubtitle,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitleTealText = TextStyle(
    color: KConstants.primaryColor,
    fontSize: KConstants.fontSizeSubtitle,
    fontWeight: FontWeight.w600,
  );

  // Textos de descrição
  static const TextStyle descriptionText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeLarge,
  );

  static const TextStyle descriptionSecondaryText = TextStyle(
    color: KConstants.textSecondaryColor,
    fontSize: KConstants.fontSizeLarge,
  );

  // Textos de corpo
  static const TextStyle bodyText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeMedium,
  );

  static const TextStyle bodySecondaryText = TextStyle(
    color: KConstants.textSecondaryColor,
    fontSize: KConstants.fontSizeMedium,
  );

  // Textos pequenos
  static const TextStyle smallText = TextStyle(
    color: KConstants.textSecondaryColor,
    fontSize: KConstants.fontSizeSmall,
  );

  static const TextStyle captionText = TextStyle(
    color: KConstants.textTertiaryColor,
    fontSize: KConstants.fontSizeExtraSmall,
  );

  // Textos de botões
  static const TextStyle buttonText = TextStyle(
    color: KConstants.textLightColor,
    fontSize: KConstants.fontSizeMedium,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonTextPrimary = TextStyle(
    color: KConstants.primaryColor,
    fontSize: KConstants.fontSizeMedium,
    fontWeight: FontWeight.w600,
  );

  // Textos de navegação
  static const TextStyle navigationText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle navigationActiveText = TextStyle(
    color: KConstants.primaryColor,
    fontSize: KConstants.fontSizeMedium,
    fontWeight: FontWeight.w600,
  );

  // Textos de erro e sucesso
  static const TextStyle errorText = TextStyle(
    color: KConstants.errorColor,
    fontSize: KConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle successText = TextStyle(
    color: KConstants.successColor,
    fontSize: KConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle warningText = TextStyle(
    color: KConstants.warningColor,
    fontSize: KConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle infoText = TextStyle(
    color: KConstants.infoColor,
    fontSize: KConstants.fontSizeMedium,
    fontWeight: FontWeight.w500,
  );

  // Textos de input
  static const TextStyle inputText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeMedium,
  );

  static const TextStyle inputLabelText = TextStyle(
    color: KConstants.textSecondaryColor,
    fontSize: KConstants.fontSizeSmall,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle inputHintText = TextStyle(
    color: KConstants.textTertiaryColor,
    fontSize: KConstants.fontSizeMedium,
  );

  // Textos de card
  static const TextStyle cardTitleText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeLarge,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardSubtitleText = TextStyle(
    color: KConstants.textSecondaryColor,
    fontSize: KConstants.fontSizeMedium,
  );

  static const TextStyle cardBodyText = TextStyle(
    color: KConstants.textPrimaryColor,
    fontSize: KConstants.fontSizeMedium,
  );
}

class KDecoration {
  // Decorações de containers
  static BoxDecoration primaryContainerDecoration = BoxDecoration(
    color: KConstants.backgroundColor,
    borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: KConstants.backgroundColor,
    borderRadius: BorderRadius.circular(KConstants.borderRadiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration inputDecoration = BoxDecoration(
    color: KConstants.backgroundColor,
    borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
    border: Border.all(color: KConstants.surfaceColor.withValues(alpha: 0.3)),
  );

  static BoxDecoration buttonDecoration = BoxDecoration(
    color: KConstants.primaryColor,
    borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
  );

  static BoxDecoration outlineButtonDecoration = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
    border: Border.all(color: KConstants.primaryColor),
  );
}

class KInputDecoration {
  static InputDecoration textFieldDecoration({
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: KConstants.textSecondaryColor)
          : null,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: KConstants.textSecondaryColor)
          : null,
      hintStyle: KTextStyle.inputHintText,
      labelStyle: KTextStyle.inputLabelText,
      filled: true,
      fillColor: KConstants.backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
        borderSide: BorderSide(
          color: KConstants.surfaceColor.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
        borderSide: BorderSide(
          color: KConstants.surfaceColor.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: KConstants.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: KConstants.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KConstants.spacingMedium,
        vertical: KConstants.spacingMedium,
      ),
    );
  }
}
