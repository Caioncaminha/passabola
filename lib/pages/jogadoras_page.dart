import 'package:flutter/material.dart';
import '../data/constants.dart';

class JogadorasPage extends StatefulWidget {
  const JogadorasPage({super.key});

  @override
  State<JogadorasPage> createState() => _JogadorasPageState();
}

class _JogadorasPageState extends State<JogadorasPage> {
  @override
  Widget build(BuildContext context) {
    const int numeroDeJogadoras = 5;

    return Scaffold(
      backgroundColor: KConstants.backgroundColor,
      body: Column(
        children: [
          // Campo de pesquisa
          Padding(
            padding: EdgeInsets.fromLTRB(
              KConstants.spacingMedium,
              KConstants.spacingMedium,
              KConstants.spacingMedium,
              KConstants.spacingSmall,
            ),
            child: TextField(
              decoration: KInputDecoration.textFieldDecoration(
                hintText: "Pesquisar jogadora...",
                prefixIcon: Icons.search,
              ),
            ),
          ),
          // Lista de jogadoras
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: KConstants.spacingSmall),
              itemCount: numeroDeJogadoras,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: KConstants.spacingMedium,
                        vertical: KConstants.spacingSmall,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: KConstants.surfaceColor
                                .withOpacity(0.3),
                          ),
                          SizedBox(width: KConstants.spacingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "NOME JOGADORA",
                                      style: KTextStyle.cardTitleText,
                                    ),
                                    Text(
                                      "STATUS",
                                      style: KTextStyle.smallText.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: KConstants.spacingExtraSmall),
                                Text(
                                  "TIME DA JOGADORA - POSIÇÃO",
                                  style: KTextStyle.bodySecondaryText,
                                ),
                                SizedBox(height: KConstants.spacingSmall),
                                Text(
                                  "DATA DE NASCIMENTO: 00/00/0000",
                                  style: KTextStyle.smallText,
                                ),
                                Text(
                                  "CPF: 000.000.000-00",
                                  style: KTextStyle.smallText,
                                ),
                                Text(
                                  "TEL: (00) 0 0000-0000",
                                  style: KTextStyle.smallText,
                                ),
                                Text(
                                  "ENDEREÇO: Rua Nome Qualquer, 10A",
                                  style: KTextStyle.smallText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: KConstants.spacingMedium,
                      thickness: 1,
                      indent: KConstants.spacingMedium,
                      endIndent: KConstants.spacingMedium,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
