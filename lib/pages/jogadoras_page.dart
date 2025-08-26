import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Pesquisar jogadora...",
                hintStyle: const TextStyle(color: Color.fromARGB(255, 123, 143, 125)),
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 123, 143, 125)),
                filled: true,
                fillColor: const Color(0xFFF3EEF4),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 201, 217, 201)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 174, 209, 174), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          // Lista de jogadoras 
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: numeroDeJogadoras,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            backgroundColor: Color(0xFFE0E0E0),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "NOME JOGADORA",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "STATUS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "TIME DA JOGADORA - POSIÇÃO",
                                  style: TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "DATA DE NASCIMENTO: 00/00/0000",
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                const Text(
                                  "CPF: 000.000.000-00",
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                const Text(
                                  "TEL: (00) 0 0000-0000",
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                const Text(
                                  "ENDEREÇO: Rua Nome Qualquer, 10A",
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 16,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
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