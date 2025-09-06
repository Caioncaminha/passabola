import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:passaabola/data/constants.dart';
import 'jogadoras_time_page.dart'; // Import da nova página de jogadoras

class Api extends StatefulWidget {
  const Api({super.key});

  @override
  State<Api> createState() => _ApiState();
}

class _ApiState extends State<Api> {
  final String apiKey = '47886f91ab8bc012bf6d156b05bd4514';
  final String baseUrl = 'https://v3.football.api-sports.io';
  final int leagueId = 74; // Futebol brasileiro feminino

  List<dynamic> teams = [];
  List<dynamic> fixtures = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    // testar se a API esta funcionando
    try {
      print('📡 Fazendo requisições para API...');
      await Future.wait([_fetchTeams(), _fetchFixtures()]);
      print('✅ Dados carregados com sucesso!');
      print('📊 Times encontrados: ${teams.length}');
      print('⚽ Jogos encontrados: ${fixtures.length}');
    } catch (e) {
      print('❌ Erro ao carregar dados: $e');
      setState(() {
        errorMessage = 'Erro ao carregar dados: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      print('🏁 Carregamento finalizado');
    }
  }

  // faz a requisição da API para pegar os dados dos times
  Future<void> _fetchTeams() async {
    final url = '$baseUrl/teams?league=$leagueId&season=2023';
    print('🏈 Fazendo requisição para times: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'x-apisports-key': apiKey},
    );

    print('📡 Resposta dos times - Status: ${response.statusCode}');
    print('📄 Body dos times: ${response.body}');
    //verifica se a requisição funcionou
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📊 Dados dos times decodificados: $data');
      //vferifica se os dados são validos
      if (data['response'] != null) {
        setState(() {
          teams = data['response'];
        });
        print('✅ Times carregados: ${teams.length}');
      } else {
        print('⚠️ Resposta dos times não contém dados válidos');
      }
    } else {
      print('❌ Erro na requisição dos times: ${response.statusCode}');
      throw Exception('Falha ao carregar times: ${response.statusCode}');
    }
  }

  // requisição da API para os jogos
  Future<void> _fetchFixtures() async {
    final url = '$baseUrl/fixtures?league=$leagueId&season=2023';
    print('⚽ Fazendo requisição para jogos: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'x-apisports-key': apiKey},
    );

    print('📡 Resposta dos jogos - Status: ${response.statusCode}');
    print('📄 Body dos jogos: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📊 Dados dos jogos decodificados: $data');

      if (data['response'] != null) {
        setState(() {
          fixtures = data['response'];
        });
        print('✅ Jogos carregados: ${fixtures.length}');
      } else {
        print('⚠️ Resposta dos jogos não contém dados válidos');
      }
    } else {
      print('❌ Erro na requisição dos jogos: ${response.statusCode}');
      throw Exception('Falha ao carregar jogos: ${response.statusCode}');
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      final time = timeString.split(':');
      return '${time[0]}:${time[1]}';
    } catch (e) {
      return timeString;
    }
  }

  /// FUNÇÃO PARA NAVEGAR PARA A PÁGINA DE JOGADORAS
  ///
  /// Esta função:
  /// 1. Recebe os dados do time clicado
  /// 2. Navega para a página de jogadoras
  /// 3. Passa os dados do time como parâmetro
  ///
  void _navigateToPlayersPage(Map<String, dynamic> team) {
    print('🔄 Navegando para página de jogadoras do time: ${team['name']}');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JogadorasTimePage(team: team)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Futebol Brasileiro Feminino'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botão de atualizar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dados da Liga (ID: $leagueId) - Temporada 2023',
                  style: KTextStyle.titleText.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar dados',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Times', icon: Icon(Icons.groups)),
                          Tab(text: 'Jogos', icon: Icon(Icons.sports_soccer)),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab de Times
                            teams.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text('Nenhum time encontrado'),
                                        SizedBox(height: 8),
                                        Text(
                                          'Verifique se a temporada 2023 tem dados disponíveis',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: teams.length,
                                    itemBuilder: (context, index) {
                                      final team = teams[index]['team'];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: ListTile(
                                          // FUNCIONALIDADE DE CLIQUE
                                          // Quando o usuário tocar no card, navega para a página de jogadoras
                                          onTap: () =>
                                              _navigateToPlayersPage(team),

                                          // Logo do time
                                          leading: team['logo'] != null
                                              ? Image.network(
                                                  team['logo'],
                                                  width: 40,
                                                  height: 40,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return const Icon(
                                                          Icons.sports_soccer,
                                                        );
                                                      },
                                                )
                                              : const Icon(Icons.sports_soccer),

                                          // Nome do time
                                          title: Text(
                                            team['name'] ??
                                                'Nome não disponível',
                                            style: KTextStyle.bodyText.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          // ID do time
                                          subtitle: Text(
                                            'ID: ${team['id']}',
                                            style: KTextStyle.bodySecondaryText,
                                          ),

                                          // Ícone indicando que é clicável
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                            // Tab de Jogos
                            fixtures.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sports_soccer,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text('Nenhum jogo encontrado'),
                                        SizedBox(height: 8),
                                        Text(
                                          'Verifique se a temporada 2023 tem dados disponíveis',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: fixtures.length,
                                    itemBuilder: (context, index) {
                                      final fixture = fixtures[index];
                                      final homeTeam = fixture['teams']['home'];
                                      final awayTeam = fixture['teams']['away'];
                                      final score = fixture['score'];
                                      final status =
                                          fixture['fixture']['status'];

                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Data e horário
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatDate(
                                                      fixture['fixture']['date'],
                                                    ),
                                                    style: KTextStyle
                                                        .bodySecondaryText,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatTime(
                                                      fixture['fixture']['date'],
                                                    ),
                                                    style: KTextStyle
                                                        .bodySecondaryText,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Times e placar
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        homeTeam['logo'] != null
                                                            ? Image.network(
                                                                homeTeam['logo'],
                                                                width: 24,
                                                                height: 24,
                                                                errorBuilder:
                                                                    (
                                                                      context,
                                                                      error,
                                                                      stackTrace,
                                                                    ) {
                                                                      return const Icon(
                                                                        Icons
                                                                            .sports_soccer,
                                                                        size:
                                                                            24,
                                                                      );
                                                                    },
                                                              )
                                                            : const Icon(
                                                                Icons
                                                                    .sports_soccer,
                                                                size: 24,
                                                              ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            homeTeam['name'] ??
                                                                'Time Casa',
                                                            style: KTextStyle
                                                                .bodyText,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Placar
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: KConstants
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${score['fulltime']['home'] ?? '-'} x ${score['fulltime']['away'] ?? '-'}',
                                                      style: KTextStyle.bodyText
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: KConstants
                                                                .primaryColor,
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            awayTeam['name'] ??
                                                                'Time Visitante',
                                                            style: KTextStyle
                                                                .bodyText,
                                                            textAlign:
                                                                TextAlign.end,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        awayTeam['logo'] != null
                                                            ? Image.network(
                                                                awayTeam['logo'],
                                                                width: 24,
                                                                height: 24,
                                                                errorBuilder:
                                                                    (
                                                                      context,
                                                                      error,
                                                                      stackTrace,
                                                                    ) {
                                                                      return const Icon(
                                                                        Icons
                                                                            .sports_soccer,
                                                                        size:
                                                                            24,
                                                                      );
                                                                    },
                                                              )
                                                            : const Icon(
                                                                Icons
                                                                    .sports_soccer,
                                                                size: 24,
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),

                                              // Status do jogo
                                              Row(
                                                children: [
                                                  Icon(
                                                    status['short'] == 'FT'
                                                        ? Icons.check_circle
                                                        : Icons.schedule,
                                                    size: 16,
                                                    color:
                                                        status['short'] == 'FT'
                                                        ? Colors.green
                                                        : Colors.orange,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    status['long'] ??
                                                        'Status não disponível',
                                                    style: KTextStyle
                                                        .bodySecondaryText
                                                        .copyWith(
                                                          color:
                                                              status['short'] ==
                                                                  'FT'
                                                              ? Colors.green
                                                              : Colors.orange,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
