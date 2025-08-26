import 'package:flutter/material.dart';
import '../data/constants.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KConstants.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- CABEÇALHO COM IMAGEM DE PERFIL ---
            SizedBox(
              height: 250,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Fundo roxo
                  Container(
                    height: 150,
                    decoration: BoxDecoration(color: KConstants.primaryColor),
                  ),
                  // Avatar de perfil posicionado
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: KConstants.backgroundColor,
                        child: CircleAvatar(
                          radius: 66,
                          backgroundColor: KConstants.surfaceColor.withOpacity(
                            0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- INFORMAÇÕES DO USUÁRIO ---
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: KConstants.spacingMedium,
              ),
              child: Column(
                children: [
                  Text("Usuário", style: KTextStyle.extraLargeTitleText),
                  SizedBox(height: KConstants.spacingExtraSmall),
                  Text(
                    "TIME DO USUÁRIO - POSIÇÃO",
                    style: KTextStyle.subtitleText,
                  ),
                  SizedBox(height: KConstants.spacingLarge),
                  Text(
                    "DATA DE NASCIMENTO: 00/00/0000\n"
                    "CPF: 000.000.000-00\n"
                    "TEL.: (00) 0 0000-0000\n"
                    "ENDEREÇO: Rua Nome Qualquer, 10A",
                    textAlign: TextAlign.left,
                    style: KTextStyle.bodyText.copyWith(
                      height: 1.5, // Espaçamento entre linhas
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: KConstants.spacingExtraLarge),

            // --- MENU DE OPÇÕES ---
            _ProfileMenuItem(
              icon: Icons.edit_note,
              text: "Sua atividade",
              color: KConstants.successColor,
              borderColor: KConstants.primaryColor,
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_none,
              text: "Notificações",
              color: KConstants.successColor,
              borderColor: KConstants.primaryColor,
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.lock_outline,
              text: "Privacidade",
              color: KConstants.successColor,
              borderColor: KConstants.primaryColor,
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.bookmark_border,
              text: "Salvos",
              color: KConstants.successColor,
              borderColor: KConstants.primaryColor,
              onTap: () {},
            ),

            // --- BOTÃO DE SAIR ---
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: KConstants.spacingExtraLarge,
                horizontal: KConstants.spacingLarge,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Lógica para sair do app
                  },
                  child: Text(
                    "Sair",
                    style: KTextStyle.titleText.copyWith(
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para os itens do menu para não repetir código
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.text,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color,
        padding: EdgeInsets.symmetric(
          vertical: KConstants.spacingMedium,
          horizontal: KConstants.spacingLarge,
        ),
        margin: EdgeInsets.only(bottom: 2), // Espaço entre os botões
        decoration: BoxDecoration(
          color: color,
          border: Border(
            top: BorderSide(width: 1.5, color: borderColor.withOpacity(0.5)),
            bottom: BorderSide(width: 1.5, color: borderColor.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: KConstants.textPrimaryColor, size: 24),
            SizedBox(width: KConstants.spacingMedium),
            Text(
              text,
              style: KTextStyle.bodyText.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
