import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex =
      0; // 0 para "Próximos jogos", 1 para "Jogos finalizados"

  @override
  Widget build(BuildContext context) {
    const Color corVerdePrincipal = Color(0xFF708F56);
    const Color corVerdeClaro = Color(0xFF8EB479);
    const Color corRosaCard = Color(0xFFE6C4C8);
    const Color corRosaClaro = Color(0xFFF9F1F2);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: corRosaClaro,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: corRosaCard, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: corRosaCard, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 230, 172, 178),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- ABAS DE JOGOS ---
            Row(
              children: [
                _buildTabItem("Próximos jogos", 0),
                const SizedBox(width: 20),
                _buildTabItem("Jogos finalizados", 1),
              ],
            ),
            const SizedBox(height: 12),

            // --- PLACEHOLDERS CINZAS ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- SEÇÃO DESTAQUES ---
            const _SectionHeader(title: "Destaques"),
            const SizedBox(height: 12),
            _buildDestaqueCard(
              imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbziMhNtB0BukzUAZ7NIzEU9bUIWpBKHDh7A&s',
              title: 'Lorem ipsum dolor sit amet',
              description:
                  'Lorem ipsum dolor sit amet consectetur adipiscing elit. Sit amet consectetur adipiscing elit quisque faucibus ex. Adipiscing elit quisque faucibus ex sapien vitae pellentesque.',
              backgroundColor: corRosaCard,
            ),
            const SizedBox(height: 24),

            // --- SEÇÃO VÍDEOS EM ALTA ---
            const _SectionHeader(title: "Vídeos em alta"),
            const SizedBox(height: 12),
            _buildVideoCard(
              title: "Título 1",
              backgroundColor: corVerdePrincipal,
            ),
            _buildShowMoreButton(corVerdeClaro),
            const SizedBox(height: 12),

            // --- SEÇÃO EVENTOS ---
            const _SectionHeader(title: "Eventos"),
            const SizedBox(height: 12),
            _buildEventoCard(
              imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbziMhNtB0BukzUAZ7NIzEU9bUIWpBKHDh7A&s',
              title: "TÍTULO DE EVENTO",
              cardColor: corRosaClaro,
              titleBarColor: corRosaCard,
            ),
            _buildShowMoreButton(corVerdeClaro),
            const SizedBox(height: 12),

            // --- SEÇÃO CAMPEÃS ---
            const _SectionHeader(title: "Campeãs"),
            const SizedBox(height: 12),
            _buildDestaqueCard(
              imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbziMhNtB0BukzUAZ7NIzEU9bUIWpBKHDh7A&s',
              title: '🏆 CAMPEÃS',
              isTitleBold: true,
              description:
                  'Lorem ipsum dolor sit amet consectetur adipiscing elit. Sit amet consectetur adipiscing elit quisque faucibus ex. Adipiscing elit quisque faucibus ex sapien vitae pellentesque.',
              backgroundColor: corRosaCard,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para os itens da aba
  Widget _buildTabItem(String text, int index) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: IntrinsicWidth(
        // 👈 mede pela largura do texto
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF708F56) : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: isSelected ? 3 : 0,
              width: double.infinity, // 👈 vira “100% do texto”
              decoration: BoxDecoration(
                color: const Color(0xFF708F56),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para os cabeçalhos de seção
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF708F56),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Widget auxiliar para os cards de "Destaques" e "Campeãs"
Widget _buildDestaqueCard({
  required String imageUrl,
  required String title,
  required String description,
  required Color backgroundColor,
  bool isTitleBold = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isTitleBold ? FontWeight.bold : FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Divider(color: Colors.black54, thickness: 1, height: 20),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Widget auxiliar para o card de "Vídeos em alta"
Widget _buildVideoCard({
  required String title,
  required Color backgroundColor,
}) {
  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        child: const Icon(
          Icons.play_circle_fill,
          color: Colors.white,
          size: 60,
        ),
      ),
    ],
  );
}

// Widget auxiliar para o card de "Eventos"
Widget _buildEventoCard({
  required String imageUrl,
  required String title,
  required Color cardColor,
  required Color titleBarColor,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: titleBarColor,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Widget auxiliar para o botão "Show more"
Widget _buildShowMoreButton(Color color) {
  return Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () {},
      child: Text(
        "Show more",
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
