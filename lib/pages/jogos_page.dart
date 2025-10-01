import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../models/jogo_models.dart';
import 'jogos_detalhes_page.dart';

class JogosPage extends StatefulWidget {
  const JogosPage({super.key});

  @override
  State<JogosPage> createState() => _JogosPageState();
}

class _JogosPageState extends State<JogosPage> {
  int _selectedTabIndex = 0;

  // --- BANCO DE DADOS SIMULADO ---

  // Criando os times que vamos usar. As formações
  final List<Time> _times = const [
    Time(
      nome: 'São Paulo',
      logoUrl: 'data:image/png;base64,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',
      experiencia: 'Nível 15',
      formacao: formation433
    ),
    Time(
      nome: 'Palmeiras',
      logoUrl: 'data:image/png;base64,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',
      experiencia: 'Nível 18',
      formacao: formation442
    ),
    Time(
      nome: 'Corinthians',
      logoUrl: 'data:image/png;base64,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',
      experiencia: 'Nível 17',
      formacao: formation433
    ),
    Time(
      nome: 'Santos',
      logoUrl: 'data:image/png;base64,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',
      experiencia: 'Nível 14',
      formacao: formation442
    ),
  ];

  // Listas de jogos que serão preenchidas
  late final List<Jogo> _proximosJogos;
  late final List<Jogo> _jogosFinalizados;

  // Preenche as listas quando o widget é criado pela primeira vez
  @override
  void initState() {
    super.initState();
    _proximosJogos = [
      Jogo(timeCasa: _times[0], timeFora: _times[1], placar: 'VS', tempo: '16:00'),
      Jogo(timeCasa: _times[2], timeFora: _times[3], placar: 'VS', tempo: '18:30'),
    ];
    _jogosFinalizados = [
      Jogo(timeCasa: _times[1], timeFora: _times[3], placar: '3 - 1', tempo: 'Finalizado', isFinalizado: true),
      Jogo(timeCasa: _times[0], timeFora: _times[2], placar: '0 - 0', tempo: 'Finalizado', isFinalizado: true),
      Jogo(timeCasa: _times[3], timeFora: _times[0], placar: '2 - 1', tempo: 'Finalizado', isFinalizado: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Escolhe qual lista de jogos mostrar com base na aba selecionada
    final List<Jogo> jogosAtuais = _selectedTabIndex == 0 ? _proximosJogos : _jogosFinalizados;

    return Scaffold(
      backgroundColor: KConstants.backgroundColor, // Fundo branco
      body: Column(
        children: [
          const SizedBox(height: KConstants.spacingSmall),
          // Container para as abas
          Container(
            color: KConstants.backgroundColor,
            padding: const EdgeInsets.symmetric(
              horizontal: KConstants.spacingMedium,
              vertical: KConstants.spacingSmall,
            ),
            child: Row(
              children: [
                _buildTabItem("Próximos jogos", 0),
                const SizedBox(width: KConstants.spacingLarge),
                _buildTabItem("Jogos finalizados", 1),
              ],
            ),
          ),
          // Lista de jogos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(KConstants.spacingMedium),
              itemCount: jogosAtuais.length,
              itemBuilder: (context, index) {
                final jogo = jogosAtuais[index];
                return _GameCard(
                  jogo: jogo,
                  onDetailsPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JogosDetalhesPage(jogo: jogo)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os itens da aba
  Widget _buildTabItem(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    const activeColor = Color(0xFF708F56); 

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: isSelected
                  ? KTextStyle.navigationText.copyWith(color: activeColor, fontWeight: FontWeight.bold)
                  : KTextStyle.navigationText,
            ),
            const SizedBox(height: KConstants.spacingExtraSmall),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: isSelected ? 3 : 0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(KConstants.borderRadiusSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para o Card de Jogo
class _GameCard extends StatelessWidget {
  final Jogo jogo;
  final VoidCallback onDetailsPressed;

  const _GameCard({required this.jogo, required this.onDetailsPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingMedium),
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      decoration: KDecoration.cardDecoration.copyWith(
        color: KConstants.primaryColor,
        border: Border(bottom: BorderSide(color: KConstants.backgroundColor.withOpacity(0.5), width: 2))
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TeamInfo(time: jogo.timeCasa),
              _ScoreInfo(score: jogo.placar, time: jogo.tempo),
              _TeamInfo(time: jogo.timeFora),
            ],
          ),
          const SizedBox(height: KConstants.spacingLarge),
          ElevatedButton(
            onPressed: onDetailsPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: KConstants.secondaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KConstants.borderRadiusLarge),
              ),
            ),
            child: Text('DETALHES', style: KTextStyle.buttonText),
          )
        ],
      ),
    );
  }
}

// Widgets auxiliares para o Card de Jogo
class _TeamInfo extends StatelessWidget {
  final Time time;
  const _TeamInfo({required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(time.logoUrl, height: 60, width: 60),
        const SizedBox(height: KConstants.spacingSmall),
        Container(
          constraints: const BoxConstraints(minWidth: 90), // Garante um tamanho mínimo
          padding: const EdgeInsets.symmetric(
            horizontal: KConstants.spacingSmall,
            vertical: KConstants.spacingExtraSmall,
          ),
          decoration: BoxDecoration(
            color: KConstants.secondaryColor,
            borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
          ),
          child: Column(
            children: [
              Text(time.nome, style: KTextStyle.smallText.copyWith(color: KConstants.textLightColor), textAlign: TextAlign.center),
              Text(time.experiencia, style: KTextStyle.captionText.copyWith(color: KConstants.textLightColor), textAlign: TextAlign.center),
            ],
          ),
        )
      ],
    );
  }
}

class _ScoreInfo extends StatelessWidget {
  final String score;
  final String time;

  const _ScoreInfo({required this.score, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(score, style: KTextStyle.extraLargeTitleText.copyWith(color: KConstants.textLightColor)),
        Text(time, style: KTextStyle.bodySecondaryText.copyWith(color: KConstants.textLightColor)),
      ],
    );
  }
}