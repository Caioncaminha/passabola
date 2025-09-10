import 'package:flutter/material.dart';
import '../data/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // --- CORES LOCAIS ---
    const Color corVerdePrincipal = KConstants.lightGreenColor;
    const Color corVerdeClaro = Color(0xFF8EB479);
    const Color corRosaCard = Color(0xFFE6C4C8);
    const Color corRosaClaro = Color(0xFFF9F1F2);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BARRA DE PESQUISA ---
            TextField(
              style: KTextStyle.inputText,
              decoration: InputDecoration(
                hintText: "Pesquisar...",
                hintStyle: KTextStyle.inputHintText,
                prefixIcon: const Icon(Icons.search, color: KConstants.textSecondaryColor),
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
                  borderSide: const BorderSide(color: KConstants.secondaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // --- ABAS DE JOGOS ---
            Row(
              children: [
                _buildTabItem("Próximos jogos", 0, corVerdePrincipal),
                const SizedBox(width: KConstants.spacingLarge),
                _buildTabItem("Jogos finalizados", 1, corVerdePrincipal),
              ],
            ),
            const SizedBox(height: KConstants.spacingMedium),

            // --- PLACEHOLDERS CINZAS ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: KConstants.surfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
                    ),
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: KConstants.surfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // --- SEÇÃO DESTAQUES ---
            _SectionHeader(title: "Destaques", color: corVerdePrincipal),
            const SizedBox(height: KConstants.spacingMedium),
            _buildDestaqueCard(
              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbziMhNtB0BukzUAZ7NIzEU9bUIWpBKHDh7A&s',
              title: 'Lorem ipsum dolor sit amet',
              description: 'Lorem ipsum dolor sit amet consectetur adipiscing elit. Sit amet consectetur adipiscing elit quisque faucibus ex. Adipiscing elit quisque faucibus ex sapien vitae pellentesque.',
              backgroundColor: corRosaCard,
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // --- SEÇÃO VÍDEOS EM ALTA ---
            _SectionHeader(title: "Vídeos em alta", color: corVerdePrincipal),
            const SizedBox(height: KConstants.spacingMedium),
            _buildVideoCard(title: "Título 1", backgroundColor: corVerdePrincipal),
            _buildShowMoreButton(corVerdeClaro),
            const SizedBox(height: KConstants.spacingMedium),

            // --- SEÇÃO EVENTOS ---
            _SectionHeader(title: "Eventos", color: corVerdePrincipal),
            const SizedBox(height: KConstants.spacingMedium),
            _buildEventoCard(
              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbziMhNtB0BukzUAZ7NIzEU9bUIWpBKHDh7A&s',
              title: "TÍTULO DE EVENTO",
              cardColor: corRosaClaro,
              titleBarColor: corRosaCard,
            ),
            _buildShowMoreButton(corVerdeClaro),
            const SizedBox(height: KConstants.spacingMedium),

            // --- SEÇÃO CAMPEÃS ---
            _SectionHeader(title: "Campeãs", color: corVerdePrincipal),
            const SizedBox(height: KConstants.spacingMedium),
            _buildDestaqueCard(
              imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSbziMhNtB0BukzUAZ7NIzEU9bUIWpBKHDh7A&s',
              title: '🏆 CAMPEÃS 🏆',
              isTitleBold: true,
              description: 'Lorem ipsum dolor sit amet consectetur adipiscing elit. Sit amet consectetur adipiscing elit quisque faucibus ex. Adipiscing elit quisque faucibus ex sapien vitae pellentesque.',
              backgroundColor: corRosaCard,
            ),
            const SizedBox(height: KConstants.spacingLarge),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para os itens da aba
  Widget _buildTabItem(String text, int index, Color selectedColor) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: isSelected 
                  ? KTextStyle.navigationText.copyWith(color: selectedColor, fontWeight: FontWeight.bold) 
                  : KTextStyle.navigationText,
            ),
            const SizedBox(height: KConstants.spacingExtraSmall),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: isSelected ? 3 : 0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(KConstants.borderRadiusSmall),
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
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
          ),
        ),
        const SizedBox(width: KConstants.spacingSmall),
        Text(title, style: KTextStyle.titleText),
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
    decoration: KDecoration.cardDecoration.copyWith(color: backgroundColor),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(KConstants.borderRadiusLarge)),
          child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: 180),
        ),
        Padding(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: isTitleBold
                    ? KTextStyle.cardTitleText.copyWith(fontWeight: FontWeight.bold)
                    : KTextStyle.cardTitleText,
              ),
              const Divider(color: KConstants.textTertiaryColor, thickness: 1, height: KConstants.spacingMedium * 1.5),
              Text(description, style: KTextStyle.cardBodyText),
            ],
          ),
        ),
      ],
    ),
  );
}

// Widget auxiliar para o card de "Vídeos em alta"
Widget _buildVideoCard({required String title, required Color backgroundColor}) {
  return Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: KConstants.spacingMedium),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(KConstants.borderRadiusLarge)),
        ),
        child: Text(title, textAlign: TextAlign.center, style: KTextStyle.buttonText),
      ),
      Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: KConstants.surfaceColor.withOpacity(0.2),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(KConstants.borderRadiusLarge)),
        ),
        child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
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
    borderRadius: BorderRadius.circular(KConstants.borderRadiusLarge),
    child: Container(
      decoration: KDecoration.cardDecoration.copyWith(
        color: cardColor,
        border: Border.all(color: KConstants.surfaceColor.withOpacity(0.2), width: 2),
        boxShadow: [],
      ),
      child: Column(
        children: [
          Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: 180),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: KConstants.spacingMedium),
            color: titleBarColor,
            child: Text(title, textAlign: TextAlign.center, style: KTextStyle.cardTitleText),
          )
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
      child: Text("Show more", style: KTextStyle.buttonTextPrimary.copyWith(color: color)),
    ),
  );
}
