import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  @override
  Widget build(BuildContext context) {
    const Color corPrincipal = Color(0xFF6A446F);
    const Color corSecundaria = Colors.green;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    decoration: const BoxDecoration(
                      color: corPrincipal,
                    ),
                  ),
                  // Avatar de perfil posicionado
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white, 
                        child: CircleAvatar(
                          radius: 66,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // --- INFORMAÇÕES DO USUÁRIO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Text(
                    "Usuário",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "TIME DO USUÁRIO - POSIÇÃO",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "DATA DE NASCIMENTO: 00/00/0000\n"
                    "CPF: 000.000.000-00\n"
                    "TEL.: (00) 0 0000-0000\n"
                    "ENDEREÇO: Rua Nome Qualquer, 10A",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.5, // Espaçamento entre linhas
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- MENU DE OPÇÕES ---
            _ProfileMenuItem(
              icon: Icons.edit_note,
              text: "Sua atividade",
              color: corSecundaria,
              borderColor: corPrincipal,
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_none,
              text: "Notificações",
              color: corSecundaria,
              borderColor: corPrincipal,
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.lock_outline,
              text: "Privacidade",
              color: corSecundaria,
              borderColor: corPrincipal,
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.bookmark_border,
              text: "Salvos",
              color: corSecundaria,
              borderColor: corPrincipal,
              onTap: () {},
            ),
            
            // --- BOTÃO DE SAIR ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Lógica para sair do app
                  },
                  child: const Text(
                    "Sair",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 2), // Espaço entre os botões
        decoration: BoxDecoration(
          color: color,
          border: Border(
            top: BorderSide(width: 1.5, color: borderColor.withOpacity(0.5)),
            bottom: BorderSide(width: 1.5, color: borderColor.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}